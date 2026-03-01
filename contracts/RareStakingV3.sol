// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Rare Staking V3
 * @notice Stake LP tokens to earn RARE dividends with time-weighted bonuses
 * @dev Upgraded for Base Chain (V3).
 */
contract RareStakingV3 is ReentrancyGuard, Ownable, Pausable {

    // --- Types ---

    struct StakeInfo {
        uint256 amount;            // LP tokens staked
        uint256 term;              // Lock term (0=7d, 1=28d, 2=84d)
        uint256 startTime;         // When staking started
        uint256 lastClaimTime;     // When rewards were last claimed
        uint256 multiplier;        // Bonus multiplier (1x, 2x, 3x)
    }

    // --- State Variables ---

    IERC20 public rareToken;
    IERC20 public lpToken;
    address public treasury; // For fees

    uint256 public constant SECONDS_PER_WEEK = 604800;
    uint256 public constant SECONDS_7_DAYS = 604800;
    uint256 public constant SECONDS_28_DAYS = 2419200;
    uint256 public constant SECONDS_84_DAYS = 7257600;

    uint256 public entryFeeNative = 0.001 ether;
    uint256 public totalLPStaked;
    uint256 public totalRewardsDistributed;

    mapping(address => StakeInfo[]) public userStakes;

    // --- Events ---

    event Staked(address indexed user, uint256 amount, uint256 term, uint256 multiplier);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(
        address _rareToken,
        address _lpToken,
        address _treasury,
        address _initialOwner
    ) Ownable(_initialOwner) {
        rareToken = IERC20(_rareToken);
        lpToken = IERC20(_lpToken);
        treasury = _treasury;
    }

    // --- External Functions ---

    /**
     * @notice Stake LP tokens for a specific term
     * @param _amount Amount of LP tokens to stake
     * @param _term Choice of term: 0 (7 days/1x), 1 (28 days/2x), 2 (84 days/3x)
     */
    function stake(uint256 _amount, uint256 _term) external payable whenNotPaused nonReentrant {
        require(_amount > 0, "Amount must be > 0");
        require(_term <= 2, "Invalid term");
        require(msg.value >= entryFeeNative, "Insufficient entry fee");

        // Fee to treasury
        (bool success, ) = payable(treasury).call{value: msg.value}("");
        require(success, "Fee transfer failed");

        // Transfer LP tokens to contract
        require(lpToken.transferFrom(msg.sender, address(this), _amount), "LP Transfer failed");

        uint256 multiplier = _term + 1; // 1x, 2x, 3x

        userStakes[msg.sender].push(StakeInfo({
            amount: _amount,
            term: _term,
            startTime: block.timestamp,
            lastClaimTime: block.timestamp,
            multiplier: multiplier
        }));

        totalLPStaked += _amount;

        emit Staked(msg.sender, _amount, _term, multiplier);
    }

    /**
     * @notice Claim rewards for a specific stake index
     */
    function claimReward(uint256 _stakeIndex) external whenNotPaused nonReentrant {
        require(_stakeIndex < userStakes[msg.sender].length, "Invalid index");
        StakeInfo storage s = userStakes[msg.sender][_stakeIndex];
        
        require(block.timestamp >= s.lastClaimTime + SECONDS_PER_WEEK, "Claim cooldown active");

        uint256 reward = _calculateReward(msg.sender, _stakeIndex);
        require(reward > 0, "No reward available");

        // Update state BEFORE transfer
        s.lastClaimTime = block.timestamp;
        totalRewardsDistributed += reward;

        require(rareToken.transfer(msg.sender, reward), "Reward transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @notice Unstake LP tokens after term expiry
     */
    function unstake(uint256 _stakeIndex) external nonReentrant {
        require(_stakeIndex < userStakes[msg.sender].length, "Invalid index");
        StakeInfo storage s = userStakes[msg.sender][_stakeIndex];
        
        uint256 lockDuration;
        if (s.term == 0) lockDuration = SECONDS_7_DAYS;
        else if (s.term == 1) lockDuration = SECONDS_28_DAYS;
        else lockDuration = SECONDS_84_DAYS;

        require(block.timestamp >= s.startTime + lockDuration, "Term still locked");

        uint256 amount = s.amount;
        
        // Remove from array (swap with last element and pop)
        userStakes[msg.sender][_stakeIndex] = userStakes[msg.sender][userStakes[msg.sender].length - 1];
        userStakes[msg.sender].pop();

        totalLPStaked -= amount;

        require(lpToken.transfer(msg.sender, amount), "LP Transfer failed");

        emit Unstaked(msg.sender, amount);
    }

    // --- Internal Functions ---

    function _calculateReward(address _user, uint256 _stakeIndex) internal view returns (uint256) {
        StakeInfo memory s = userStakes[_user][_stakeIndex];
        
        // Placeholder logic for RARE dividend calculation
        // In the original, this was based on a percentage of the contract's RARE balance
        uint256 contractBalance = rareToken.balanceOf(address(this));
        if (totalLPStaked == 0) return 0;
        
        // Simplified weight: (user_amount * multiplier) / total_lp_staked
        // Then take a portion (e.g., 1%) of the pool
        uint256 weight = (s.amount * s.multiplier * 1e18) / totalLPStaked;
        uint256 reward = (contractBalance * weight) / 100e18; // 1% of pool as base reward

        return reward;
    }

    // --- Admin Functions ---

    function setEntryFee(uint256 _newFee) external onlyOwner {
        entryFeeNative = _newFee;
    }

    function setTreasury(address _newTreasury) external onlyOwner {
        treasury = _newTreasury;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
