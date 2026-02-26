// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Rare Fountain V2
 * @notice Dual-pool distribution system with Stake-to-Claim and Bot Protection
 * @dev Upgraded from 0.6.x to 0.8.20. Implements reentrancy protection and 24h rate limiting.
 */
contract RareFountainV2 is ReentrancyGuard, Ownable, Pausable {

    // --- State Variables ---

    IERC20 public rareToken;
    address public stakingContract;
    address public lotteryContract;

    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public poolBalance = 100 * 10**18; // 100 RARE per pool (placeholder)
    uint256 public stakeRequirement = 10 * 10**18; // 10 RARE or Native equivalent

    bool public regPeriod = true; // Alternates between Pool A and Pool B
    uint256 public regIncA; // Registration counter for Pool A
    uint256 public regIncB; // Registration counter for Pool B
    uint256 public cycleCount;

    mapping(address => bool) public registeredA;
    mapping(address => bool) public registeredB;
    mapping(address => uint256) public lastRegistrationTimestamp;

    // --- Events ---

    event Registered(address indexed user, bool poolA, uint256 cycle);
    event Claimed(address indexed user, uint256 amount, uint256 cycle);
    event PoolFlipped(uint256 newCycle, bool nowPoolA);

    constructor(
        address _rareToken,
        address _stakingContract,
        address _lotteryContract,
        address _initialOwner
    ) Ownable(_initialOwner) {
        rareToken = IERC20(_rareToken);
        stakingContract = _stakingContract;
        lotteryContract = _lotteryContract;
    }

    // --- External Functions ---

    /**
     * @notice Register for the current active distribution pool
     * @dev Implements 24h rate limit and stake-to-claim logic
     */
    function register() external payable whenNotPaused nonReentrant {
        require(
            block.timestamp >= lastRegistrationTimestamp[msg.sender] + SECONDS_PER_DAY,
            "Rate limit: 24h cooldown"
        );
        
        // Stake-to-Claim Verification (Simplified for now: check balance or msg.value)
        // In V2, we might want to actually lock the stake
        require(
            msg.value >= 0.001 ether || rareToken.balanceOf(msg.sender) >= stakeRequirement,
            "Stake requirement not met"
        );

        if (regPeriod) {
            require(!registeredA[msg.sender], "Already registered for Pool A");
            registeredA[msg.sender] = true;
            regIncA++;
            emit Registered(msg.sender, true, cycleCount);
        } else {
            require(!registeredB[msg.sender], "Already registered for Pool B");
            registeredB[msg.sender] = true;
            regIncB++;
            emit Registered(msg.sender, false, cycleCount);
        }

        lastRegistrationTimestamp[msg.sender] = block.timestamp;
    }

    /**
     * @notice Claim from the previously completed pool
     */
    function claim() external whenNotPaused nonReentrant {
        uint256 amount;
        
        // If we are currently in Pool B registration, Pool A is available to claim
        if (!regPeriod) {
            require(registeredA[msg.sender], "No claim available in Pool A");
            require(regIncA > 0, "Pool A is empty");
            
            amount = poolBalance / regIncA;
            registeredA[msg.sender] = false;
            // Note: In a production environment, we'd need to handle rounding/remainders
        } else {
            // If we are currently in Pool A registration, Pool B is available to claim
            require(registeredB[msg.sender], "No claim available in Pool B");
            require(regIncB > 0, "Pool B is empty");
            
            amount = poolBalance / regIncB;
            registeredB[msg.sender] = false;
        }

        require(amount > 0, "Claim amount is zero");
        require(rareToken.transfer(msg.sender, amount), "Transfer failed");
        
        emit Claimed(msg.sender, amount, cycleCount);
    }

    /**
     * @notice Flip the active pool and release incentives
     * @dev Triggered by bounty hunters or automation every 24h
     */
    function flipPool() external whenNotPaused nonReentrant {
        // Logic to ensure 24h has passed since last flip
        // Logic to transfer remainders to Lottery/Staking
        
        regPeriod = !regPeriod;
        cycleCount++;
        
        // Reset the registrations for the pool we are about to enter
        if (regPeriod) {
            regIncA = 0;
            // Note: This requires a way to clear the mapping or use a cycle-based mapping
        } else {
            regIncB = 0;
        }

        emit PoolFlipped(cycleCount, regPeriod);
    }

    // --- Admin Functions ---

    function setPoolBalance(uint256 _amount) external onlyOwner {
        poolBalance = _amount;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
