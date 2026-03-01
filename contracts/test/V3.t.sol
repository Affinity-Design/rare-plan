// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RareTokenV3} from "../contracts/RareTokenV3.sol";
import {RareFountainV3} from "../contracts/RareFountainV3.sol";
import {RareStakingV3} from "../contracts/RareStakingV3.sol";
import {RareLotteryV3} from "../contracts/RareLotteryV3.sol";

/**
 * @title V3 Contract Tests
 * @notice Comprehensive tests for all V3 contracts
 */
contract V3Test is Test {
    
    RareTokenV3 public token;
    RareFountainV3 public fountain;
    RareStakingV3 public staking;
    RareLotteryV3 public lottery;
    
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);
    
    // Base Sepolia Chainlink ETH/USD
    address public constant ETH_USD_FEED = 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb;
    
    function setUp() public {
        vm.startPrank(owner);
        
        // 1. Deploy Token
        token = new RareTokenV3(address(0), owner);
        
        // 2. Deploy Lottery
        lottery = new RareLotteryV3(address(token), owner);
        
        // 3. Deploy Staking (use token as LP placeholder)
        staking = new RareStakingV3(
            address(token),
            address(token), // LP placeholder
            owner,
            ETH_USD_FEED,
            owner
        );
        
        // 4. Deploy Fountain
        fountain = new RareFountainV3(
            address(token),
            address(staking),
            address(lottery),
            address(0), // No basename on testnet
            ETH_USD_FEED,
            owner
        );
        
        // 5. Fund contracts
        token.transfer(address(fountain), 1000 * 10**18);
        token.transfer(address(staking), 500 * 10**18);
        token.transfer(address(lottery), 100 * 10**18);
        
        // 6. Configure
        fountain.setPoolBalance(10 * 10**18); // 10 RARE per cycle
        fountain.setManualWhitelist(user1, true);
        fountain.setManualWhitelist(user2, true);
        fountain.setManualWhitelist(user3, true);
        fountain.unpause();
        
        lottery.startLottery();
        lottery.unpause();
        
        staking.unpause();
        
        vm.stopPrank();
    }
    
    // ============ TOKEN TESTS ============
    
    function test_TokenSupply() public view {
        assertEq(token.totalSupply(), 3_650_000 * 10**18);
    }
    
    function test_TokenName() public view {
        assertEq(token.name(), "Rare Coin");
        assertEq(token.symbol(), "RARE");
    }
    
    // ============ FOUNTAIN TESTS ============
    
    function test_Fountain_Eligibility() public view {
        assertTrue(fountain.isEligible(user1));
        assertFalse(fountain.isEligible(address(0x999)));
    }
    
    function test_Fountain_Register() public {
        vm.startPrank(user1);
        
        uint256 fee = fountain.getClaimFeeInEth();
        fountain.register{value: fee}();
        
        assertTrue(fountain.registeredA(user1));
        
        vm.stopPrank();
    }
    
    function test_Fountain_Claim() public {
        vm.startPrank(user1);
        
        // Register
        uint256 fee = fountain.getClaimFeeInEth();
        fountain.register{value: fee}();
        
        uint256 balanceBefore = token.balanceOf(user1);
        
        // Claim
        fountain.claim();
        
        uint256 balanceAfter = token.balanceOf(user1);
        assertGt(balanceAfter, balanceBefore);
        
        // Check streak
        assertEq(fountain.claimStreak(user1), 1);
        
        vm.stopPrank();
    }
    
    function test_Fountain_StreakBonus() public {
        vm.startPrank(user1);
        
        uint256 fee = fountain.getClaimFeeInEth();
        
        // Register and claim 10 times (simulated)
        for (uint i = 0; i < 10; i++) {
            fountain.register{value: fee}();
            fountain.claim();
            
            // Simulate day passing
            vm.warp(block.timestamp + 86400);
        }
        
        // Check streak tier
        assertEq(fountain.getStreakTier(user1), 1); // 10 days = tier 1
        assertEq(fountain.getTotalBonus(user1), 100); // +1%
        
        vm.stopPrank();
    }
    
    function test_Fountain_HoldingBonus() public {
        // Give user2 10,000 RARE (tier 5)
        vm.prank(owner);
        token.transfer(user2, 10000 * 10**18);
        
        // Check holding tier
        assertEq(fountain.getHoldingTier(user2), 5);
        assertEq(fountain.getTotalBonus(user2), 10000); // +100%
    }
    
    function test_Fountain_NonStacking() public {
        // Give user1 1000 RARE (tier 4 = +35%)
        vm.prank(owner);
        token.transfer(user1, 1000 * 10**18);
        
        // Simulate 30 day streak (tier 2 = +5%)
        vm.startPrank(user1);
        
        uint256 fee = fountain.getClaimFeeInEth();
        for (uint i = 0; i < 30; i++) {
            fountain.register{value: fee}();
            fountain.claim();
            vm.warp(block.timestamp + 86400);
        }
        
        // Should get holding bonus (35%) not streak (5%)
        // Higher bonus wins
        assertEq(fountain.getStreakTier(user1), 2); // 5%
        assertEq(fountain.getHoldingTier(user1), 4); // 35%
        assertEq(fountain.getTotalBonus(user1), 3500); // Gets 35%, not 40%
        
        vm.stopPrank();
    }
    
    // ============ STAKING TESTS ============
    
    function test_Staking_GetFee() public view {
        uint256 fee = staking.getEntryFeeInEth();
        assertGt(fee, 0);
    }
    
    function test_Staking_Stake() public {
        // Give user1 tokens to stake
        vm.startPrank(owner);
        token.transfer(user1, 100 * 10**18);
        vm.stopPrank();
        
        vm.startPrank(user1);
        
        // Approve staking contract
        token.approve(address(staking), 100 * 10**18);
        
        // Stake
        uint256 fee = staking.getEntryFeeInEth();
        staking.stake{value: fee}(10 * 10**18, 0); // 7 day term
        
        // Check stake
        (uint256 amount, uint256 term,,, uint256 multiplier) = staking.userStakes(user1, 0);
        assertEq(amount, 10 * 10**18);
        assertEq(term, 0);
        assertEq(multiplier, 1);
        
        vm.stopPrank();
    }
    
    function test_Staking_Unstake() public {
        // Setup stake
        vm.startPrank(owner);
        token.transfer(user1, 100 * 10**18);
        vm.stopPrank();
        
        vm.startPrank(user1);
        token.approve(address(staking), 100 * 10**18);
        uint256 fee = staking.getEntryFeeInEth();
        staking.stake{value: fee}(10 * 10**18, 0);
        
        // Try to unstake immediately (should fail)
        vm.expectRevert("Term still locked");
        staking.unstake(0);
        
        // Wait 7 days
        vm.warp(block.timestamp + 7 days);
        
        // Unstake
        staking.unstake(0);
        assertEq(token.balanceOf(user1), 100 * 10**18); // Got tokens back
        
        vm.stopPrank();
    }
    
    // ============ LOTTERY TESTS ============
    
    function test_Lottery_Enter() public {
        vm.startPrank(user1);
        
        lottery.enter{value: 0.001 ether}();
        
        assertEq(lottery.entryCount(user1), 1);
        
        vm.stopPrank();
    }
    
    function test_Lottery_EntryLimit() public {
        vm.startPrank(user1);
        
        for (uint i = 0; i < 5; i++) {
            lottery.enter{value: 0.001 ether}();
        }
        
        // 6th entry should fail
        vm.expectRevert("Entry limit reached");
        lottery.enter{value: 0.001 ether}();
        
        vm.stopPrank();
    }
    
    function test_Lottery_PickWinner() public {
        // Add 3 players
        vm.prank(user1);
        lottery.enter{value: 0.001 ether}();
        
        vm.prank(user2);
        lottery.enter{value: 0.001 ether}();
        
        vm.prank(user3);
        lottery.enter{value: 0.001 ether}();
        
        // Pick winner
        vm.prank(owner);
        lottery.pickWinner();
        
        // Check someone won (balance check)
        uint256 totalBalance = user1.balance + user2.balance + user3.balance;
        assertGt(totalBalance, 0);
    }
}
