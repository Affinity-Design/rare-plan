// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title Rare Staking V3
 * @notice Stake LP tokens to earn RARE dividends with time-weighted bonuses
 * @dev Upgraded for Base Chain (V3) with Chainlink USD oracle for fees
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
    address public treasury;
    AggregatorV3Interface internal ethUsdPriceFeed;

    uint256 public constant SECONDS_PER_WEEK = 604800;
    uint256 public constant SECONDS_7_DAYS = 604800;
    uint256 public constant SECONDS_28_DAYS = 2419200;
    uint256 public constant SECONDS_84_DAYS = 7257600;

    // Fee in USD (0.10 USD = 10 cents, stored as 18 decimals)
    uint256 public entryFeeUsd = 0.1 * 10**18; // $0.10
    
    // RARE holding thresholds for perks (replaces NFT system)
    uint256 public constant PERK_TIER_1 = 1 * 10**18;       // 1 RARE
    uint256 public constant PERK_TIER_2 = 10 * 10**18;      // 10 RARE
    uint256 public constant PERK_TIER_3 = 100 * 10**18;     // 100 RARE
    uint256 public constant PERK_TIER_4 = 1000 * 10**18;    // 1,000 RARE
    uint256 public constant PERK_TIER_5 = 10000 * 10**18;   // 10,000 RARE

    // Bonus values (in basis points, 100 = 1%)
    uint256 public constant BONUS_TIER_1 = 100;   // +1%
    uint256 public constant BONUS_TIER_2 = 500;   // +5%
    uint256 public constant BONUS_TIER_3 = 1500;  // +15%
    uint256 public constant BONUS_TIER_4 = 3500;  // +35%
    uint256 public constant BONUS_TIER_5 = 10000; // +100%

    uint256 public totalLPStaked;
    uint256 public totalRewardsDistributed;

    mapping(address => StakeInfo[]) public userStakes;

    // --- Events ---

    event Staked(address indexed user, uint256 amount, uint256 term, uint256 multiplier, uint256 feePaid);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount, uint256 perkTier);
    event FeeUpdated(uint256 newFeeUsd);

    constructor(
        address _rareToken,
        address _lpToken,
        address _treasury,
        address _ethUsdPriceFeed, // Base ETH/USD Chainlink feed
        address _initialOwner
    ) Ownable(_initialOwner) {
        rareToken = IERC20(_rareToken);
        lpToken = IERC20(_lpToken);
        treasury = _treasury;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    // --- External Functions ---

    /**
     * @notice Get current ETH price from Chainlink
     */
    function getEthPrice() public view returns (int256) {
        (
            /* uint80 roundId */,
            int256 price,
            /* uint256 startedAt */,
            /* uint256 timeStamp */,
            /* uint80 answeredInRound */
        ) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid ETH price");
        return price;
    }

    /**
     * @notice Calculate ETH fee equivalent to USD fee
     * @return ethFee ETH amount required for the USD fee
     */
    function getEntryFeeInEth() public view returns (uint256) {
        int256 ethPrice = getEthPrice(); // Price in 8 decimals (Chainlink standard)
        // ethPrice is USD per ETH with 8 decimals
        // entryFeeUsd is in 18 decimals
        // Result should be in wei (18 decimals)
        return (entryFeeUsd * 10**8) / uint256(ethPrice);
    }

    /**
     * @notice Get perk tier based on RARE holdings
     * @param _user Address to check
     * @return tier 0-5 (0 = no perks, 5 = max perks)
     */
    function getPerkTier(address _user) public view returns (uint256) {
        uint256 balance = rareToken.balanceOf(_user);
        
        if (balance >= PERK_TIER_5) return 5;
        if (balance >= PERK_TIER_4) return 4;
        if (balance >= PERK_TIER_3) return 3;
        if (balance >= PERK_TIER_2) return 2;
        if (balance >= PERK_TIER_1) return 1;
        return 0;
    }

    /**
     * @notice Get bonus percentage for a user based on their RARE holdings
     * @param _user Address to check
     * @return bonusBps Bonus in basis points
     */
    function getHoldingBonus(address _user) public view returns (uint256) {
        uint256 tier = getPerkTier(_user);
        
        if (tier == 5) return BONUS_TIER_5;
        if (tier == 4) return BONUS_TIER_4;
        if (tier == 3) return BONUS_TIER_3;
        if (tier == 2) return BONUS_TIER_2;
        if (tier == 1) return BONUS_TIER_1;
        return 0;
    }

    /**
     * @notice Stake LP tokens for a specific term
     * @param _amount Amount of LP tokens to stake
     * @param _term Choice of term: 0 (7 days/1x), 1 (28 days/2x), 2 (84 days/3x)
     */
    function stake(uint256 _amount, uint256 _term) external payable whenNotPaused nonReentrant {
        require(_amount > 0, "Amount must be > 0");
        require(_term <= 2, "Invalid term");
        
        uint256 requiredFee = getEntryFeeInEth();
        require(msg.value >= requiredFee, "Insufficient entry fee");

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

        emit Staked(msg.sender, _amount, _term, multiplier, msg.value);
    }

    /**
     * @notice Claim rewards for a specific stake index
     */
    function claimReward(uint256 _stakeIndex) external whenNotPaused nonReentrant {
        require(_stakeIndex < userStakes[msg.sender].length, "Invalid index");
        StakeInfo storage s = userStakes[msg.sender][_stakeIndex];
        
        require(block.timestamp >= s.lastClaimTime + SECONDS_PER_WEEK, "Claim cooldown active");

        uint256 baseReward = _calculateReward(msg.sender, _stakeIndex);
        
        // Apply holding bonus
        uint256 holdingBonus = getHoldingBonus(msg.sender);
        uint256 totalReward = baseReward + (baseReward * holdingBonus / 10000);
        
        require(totalReward > 0, "No reward available");

        // Update state BEFORE transfer
        s.lastClaimTime = block.timestamp;
        totalRewardsDistributed += totalReward;

        require(rareToken.transfer(msg.sender, totalReward), "Reward transfer failed");

        emit RewardClaimed(msg.sender, totalReward, getPerkTier(msg.sender));
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
        
        uint256 contractBalance = rareToken.balanceOf(address(this));
        if (totalLPStaked == 0) return 0;
        
        // Weight: (user_amount * multiplier) / total_lp_staked
        // Take 1% of pool as base weekly reward
        uint256 weight = (s.amount * s.multiplier * 1e18) / totalLPStaked;
        uint256 reward = (contractBalance * weight) / 100e18;

        return reward;
    }

    // --- Admin Functions ---

    function setEntryFeeUsd(uint256 _newFeeUsd) external onlyOwner {
        entryFeeUsd = _newFeeUsd;
        emit FeeUpdated(_newFeeUsd);
    }

    function setTreasury(address _newTreasury) external onlyOwner {
        treasury = _newTreasury;
    }

    function setPriceFeed(address _newPriceFeed) external onlyOwner {
        ethUsdPriceFeed = AggregatorV3Interface(_newPriceFeed);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
