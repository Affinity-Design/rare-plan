// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @dev Interface for Basenames (Base ENS)
 */
interface IBasenameRegistry {
    function balanceOf(address owner) external view returns (uint256);
}

/**
 * @title Rare Fountain V3
 * @notice Autonomous Dual-pool distribution system with Streak Multipliers & USD-based fees
 * @dev Base Chain (V3) with Chainlink oracle for fees
 */
contract RareFountainV3 is ReentrancyGuard, Ownable, Pausable {

    // --- State Variables ---

    IERC20 public rareToken;
    IBasenameRegistry public basenameRegistry;
    address public stakingContract;
    address public lotteryContract;
    AggregatorV3Interface internal ethUsdPriceFeed;

    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public poolBalance = 100 * 10**18; 
    
    // Fee in USD ($0.10 = 10 cents, stored as 18 decimals)
    uint256 public claimFeeUsd = 0.1 * 10**18;
    
    // --- Whitelist Tier Config ---
    uint256 public rareHoldingThreshold = 1000 * 10**18;

    bool public regPeriod = true; 
    uint256 public regIncA; 
    uint256 public regIncB; 
    uint256 public cycleCount;
    uint256 public lastFlipTimestamp;

    mapping(address => bool) public registeredA;
    mapping(address => bool) public registeredB;
    mapping(address => uint256) public lastRegistrationTimestamp;

    // --- Streak System ---
    mapping(address => uint256) public claimStreak;
    mapping(address => uint256) public lastClaimDay;

    // Streak thresholds for perks
    uint256 public constant STREAK_TIER_1 = 10;    // 10 days
    uint256 public constant STREAK_TIER_2 = 30;    // 30 days
    uint256 public constant STREAK_TIER_3 = 60;    // 60 days
    uint256 public constant STREAK_TIER_4 = 150;   // 150 days
    uint256 public constant STREAK_TIER_5 = 365;   // 365 days

    // Streak bonus values (in basis points)
    uint256 public constant STREAK_BONUS_1 = 100;   // +1%
    uint256 public constant STREAK_BONUS_2 = 500;   // +5%
    uint256 public constant STREAK_BONUS_3 = 1500;  // +15%
    uint256 public constant STREAK_BONUS_4 = 3500;  // +35%
    uint256 public constant STREAK_BONUS_5 = 10000; // +100%

    // Holding bonus values (in basis points) - same tiers
    uint256 public constant HOLD_BONUS_1 = 100;    // +1%
    uint256 public constant HOLD_BONUS_2 = 500;    // +5%
    uint256 public constant HOLD_BONUS_3 = 1500;   // +15%
    uint256 public constant HOLD_BONUS_4 = 3500;   // +35%
    uint256 public constant HOLD_BONUS_5 = 10000;  // +100%

    // --- RARE Holding Perks (replaces NFT system) ---
    uint256 public constant HOLD_TIER_1 = 1 * 10**18;       // 1 RARE
    uint256 public constant HOLD_TIER_2 = 10 * 10**18;      // 10 RARE
    uint256 public constant HOLD_TIER_3 = 100 * 10**18;     // 100 RARE
    uint256 public constant HOLD_TIER_4 = 1000 * 10**18;    // 1,000 RARE
    uint256 public constant HOLD_TIER_5 = 10000 * 10**18;   // 10,000 RARE

    // --- Events ---

    event Registered(address indexed user, bool poolA, uint256 cycle, uint256 feePaid);
    event Claimed(address indexed user, uint256 amount, uint256 cycle, uint256 streak, uint256 totalBonus);
    event PoolFlipped(uint256 newCycle, bool nowPoolA, uint256 unclaimedToLotto);
    event ThresholdUpdated(uint256 newThreshold);
    event FeeUpdated(uint256 newFeeUsd);
    event StreakReset(address indexed user, uint256 previousStreak);

    constructor(
        address _rareToken,
        address _stakingContract,
        address _lotteryContract,
        address _basenameRegistry,
        address _ethUsdPriceFeed,
        address _initialOwner
    ) Ownable(_initialOwner) {
        rareToken = IERC20(_rareToken);
        stakingContract = _stakingContract;
        lotteryContract = _lotteryContract;
        basenameRegistry = IBasenameRegistry(_basenameRegistry);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        lastFlipTimestamp = block.timestamp;
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
     */
    function getClaimFeeInEth() public view returns (uint256) {
        int256 ethPrice = getEthPrice();
        return (claimFeeUsd * 10**8) / uint256(ethPrice);
    }

    /**
     * @notice Verify if a user is eligible to claim
     */
    function isEligible(address _user) public view returns (bool) {
        // Method 1: Manual Whitelist
        if (manualWhitelist[_user]) return true;

        // Method 2: RARE Token Holding
        if (rareToken.balanceOf(_user) >= rareHoldingThreshold) return true;

        // Method 3: Base Username (Basenames)
        if (address(basenameRegistry) != address(0)) {
            if (basenameRegistry.balanceOf(_user) > 0) return true;
        }

        return false;
    }

    /**
     * @notice Get streak tier for a user
     */
    function getStreakTier(address _user) public view returns (uint256) {
        uint256 streak = claimStreak[_user];
        
        if (streak >= STREAK_TIER_5) return 5;
        if (streak >= STREAK_TIER_4) return 4;
        if (streak >= STREAK_TIER_3) return 3;
        if (streak >= STREAK_TIER_2) return 2;
        if (streak >= STREAK_TIER_1) return 1;
        return 0;
    }

    /**
     * @notice Get holding tier for a user
     */
    function getHoldingTier(address _user) public view returns (uint256) {
        uint256 balance = rareToken.balanceOf(_user);
        
        if (balance >= HOLD_TIER_5) return 5;
        if (balance >= HOLD_TIER_4) return 4;
        if (balance >= HOLD_TIER_3) return 3;
        if (balance >= HOLD_TIER_2) return 2;
        if (balance >= HOLD_TIER_1) return 1;
        return 0;
    }

    /**
     * @notice Get total bonus for a user - MAX of streak OR holding (they don't stack!)
     * @dev You either earn bonus through dedication (streak) OR investment (holding)
     */
    function getTotalBonus(address _user) public view returns (uint256) {
        uint256 streakBonus;
        uint256 streakTier = getStreakTier(_user);
        
        if (streakTier == 5) streakBonus = STREAK_BONUS_5;
        else if (streakTier == 4) streakBonus = STREAK_BONUS_4;
        else if (streakTier == 3) streakBonus = STREAK_BONUS_3;
        else if (streakTier == 2) streakBonus = STREAK_BONUS_2;
        else if (streakTier == 1) streakBonus = STREAK_BONUS_1;

        uint256 holdingBonus;
        uint256 holdingTier = getHoldingTier(_user);
        
        if (holdingTier == 5) holdingBonus = HOLD_BONUS_5;
        else if (holdingTier == 4) holdingBonus = HOLD_BONUS_4;
        else if (holdingTier == 3) holdingBonus = HOLD_BONUS_3;
        else if (holdingTier == 2) holdingBonus = HOLD_BONUS_2;
        else if (holdingTier == 1) holdingBonus = HOLD_BONUS_1;

        // Return the HIGHER bonus - they don't stack!
        // Choose your path: Dedication (streak) OR Investment (holding)
        return streakBonus > holdingBonus ? streakBonus : holdingBonus;
    }

    /**
     * @notice Register for the current active distribution pool
     */
    function register() external payable whenNotPaused nonReentrant {
        require(
            block.timestamp >= lastRegistrationTimestamp[msg.sender] + SECONDS_PER_DAY,
            "Rate limit: 24h cooldown"
        );
        
        require(isEligible(msg.sender), "Not eligible");

        // Check and collect USD-based fee
        uint256 requiredFee = getClaimFeeInEth();
        require(msg.value >= requiredFee, "Insufficient fee");
        
        // Send fee to lottery contract
        if (msg.value > 0) {
            (bool success, ) = payable(lotteryContract).call{value: msg.value}("");
            require(success, "Fee transfer failed");
        }

        // Registration Logic
        if (regPeriod) {
            require(!registeredA[msg.sender], "Already registered for Pool A");
            registeredA[msg.sender] = true;
            regIncA++;
            emit Registered(msg.sender, true, cycleCount, msg.value);
        } else {
            require(!registeredB[msg.sender], "Already registered for Pool B");
            registeredB[msg.sender] = true;
            regIncB++;
            emit Registered(msg.sender, false, cycleCount, msg.value);
        }

        lastRegistrationTimestamp[msg.sender] = block.timestamp;
    }

    /**
     * @notice Claim from the previously completed pool
     */
    function claim() external whenNotPaused nonReentrant {
        uint256 baseAmount;
        uint256 currentDay = block.timestamp / SECONDS_PER_DAY;
        
        if (!regPeriod) {
            require(registeredA[msg.sender], "No claim available in Pool A");
            require(regIncA > 0, "Pool A is empty");
            baseAmount = poolBalance / regIncA;
            registeredA[msg.sender] = false;
        } else {
            require(registeredB[msg.sender], "No claim available in Pool B");
            require(regIncB > 0, "Pool B is empty");
            baseAmount = poolBalance / regIncB;
            registeredB[msg.sender] = false;
        }

        require(baseAmount > 0, "Claim amount is zero");

        // --- Streak System ---
        // Check if user claimed yesterday (streak continuation)
        if (lastClaimDay[msg.sender] == currentDay - 1) {
            claimStreak[msg.sender]++;
        } else if (lastClaimDay[msg.sender] < currentDay - 1) {
            // Missed a day - reset streak!
            if (claimStreak[msg.sender] > 0) {
                emit StreakReset(msg.sender, claimStreak[msg.sender]);
            }
            claimStreak[msg.sender] = 1;
        }
        // If claiming same day, streak stays the same
        
        lastClaimDay[msg.sender] = currentDay;

        // Calculate bonus
        uint256 totalBonus = getTotalBonus(msg.sender);
        uint256 totalAmount = baseAmount + (baseAmount * totalBonus / 10000);

        require(rareToken.transfer(msg.sender, totalAmount), "Transfer failed");
        
        emit Claimed(msg.sender, totalAmount, cycleCount, claimStreak[msg.sender], totalBonus);
    }

    /**
     * @notice Flip the active pool - unclaimed tokens go to lottery
     * @dev Autonomous: Can be called by anyone every 24 hours
     */
    function flipPool() external whenNotPaused nonReentrant {
        require(block.timestamp >= lastFlipTimestamp + SECONDS_PER_DAY, "Flip: 24h not passed");
        
        // Calculate unclaimed tokens before flip
        uint256 unclaimed;
        if (regPeriod) {
            // Pool A was claiming, now switching to Pool B
            // Unclaimed = registeredA count * poolBalance / regIncA... simplified:
            unclaimed = poolBalance * (regIncA > 0 ? (regIncA - _countClaimedA()) : regIncA) / (regIncA > 0 ? regIncA : 1);
        } else {
            unclaimed = poolBalance * (regIncB > 0 ? (regIncB - _countClaimedB()) : regIncB) / (regIncB > 0 ? regIncB : 1);
        }

        // Send unclaimed to lottery
        if (unclaimed > 0 && address(lotteryContract) != address(0)) {
            rareToken.transfer(lotteryContract, unclaimed);
        }

        regPeriod = !regPeriod;
        cycleCount++;
        lastFlipTimestamp = block.timestamp;
        
        if (regPeriod) {
            regIncA = 0;
        } else {
            regIncB = 0;
        }

        emit PoolFlipped(cycleCount, regPeriod, unclaimed);
    }

    // --- Internal Functions ---

    function _countClaimedA() internal pure returns (uint256) {
        // Simplified - in production, track claims
        return 0;
    }

    function _countClaimedB() internal pure returns (uint256) {
        return 0;
    }

    // --- State Variables (Manual Whitelist) ---
    mapping(address => bool) public manualWhitelist;

    // --- Admin Functions ---

    function setClaimFeeUsd(uint256 _newFeeUsd) external onlyOwner {
        claimFeeUsd = _newFeeUsd;
        emit FeeUpdated(_newFeeUsd);
    }

    function setRareThreshold(uint256 _amount) external onlyOwner {
        rareHoldingThreshold = _amount;
        emit ThresholdUpdated(_amount);
    }

    function setManualWhitelist(address _user, bool _status) external onlyOwner {
        manualWhitelist[_user] = _status;
    }

    function setBasenameRegistry(address _registry) external onlyOwner {
        basenameRegistry = IBasenameRegistry(_registry);
    }

    function setLotteryContract(address _lottery) external onlyOwner {
        lotteryContract = _lottery;
    }

    function setPoolBalance(uint256 _amount) external onlyOwner {
        poolBalance = _amount;
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
