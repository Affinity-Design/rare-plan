// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title RareWager
 * @notice Price prediction game with hybrid fee model
 * @dev Users bet RARE on BTC/USD direction, ETH entry fee + 5% win fee
 *
 * Fee Model:
 *   - Entry: $1.50 USD in ETH (oracle-calculated)
 *   - Win: 5% of profit
 *   - Lose: 0% (all RARE to pool)
 *
 * All fees go to Rare Pool treasury
 */
contract RareWager is Ownable, ReentrancyGuard, Pausable {

    // ============================================
    // CONSTANTS
    // ============================================

    uint256 public constant MAX_POOL_PERCENT = 10; // Max 10% of pool per wager
    uint256 public constant MIN_WAGER = 50 * 1e18; // 50 RARE minimum
    uint256 public constant MAX_WAGER = 10000 * 1e18; // 10,000 RARE maximum
    uint256 public constant BET_DURATION = 5 minutes; // 5 minute prediction window
    uint256 public constant WIN_FEE_PERCENT = 5; // 5% fee on winnings
    uint256 public constant COOLDOWN = 10 minutes; // Cooldown between bets

    // ============================================
    // STATE VARIABLES
    // ============================================

    // Tokens
    IERC20 public immutable rareToken;

    // Oracles
    AggregatorV3Interface public ethUsdFeed; // ETH/USD price feed
    AggregatorV3Interface public btcUsdFeed; // BTC/USD price feed

    // Pool
    uint256 public poolBalance;
    uint256 public lockedBalance;
    address public treasury; // Rare Pool treasury

    // Fee settings (adjustable by owner)
    uint256 public entryFeeUsd = 1.5e18; // $1.50 in 18 decimals
    uint256 public winFeePercent = WIN_FEE_PERCENT;

    // Bet tracking
    mapping(bytes32 => Bet) public bets;
    mapping(address => uint256) public lastBetTime;
    mapping(address => uint256) public activeBets; // Number of active bets per user

    // Statistics
    uint256 public totalBets;
    uint256 public totalWins;
    uint256 public totalLosses;
    uint256 public totalVolume;
    uint256 public totalFeesCollected;

    // ============================================
    // STRUCTS
    // ============================================

    struct Bet {
        address player;
        uint256 amount; // RARE wagered
        bool direction; // true = UP, false = DOWN
        int256 startPrice; // BTC/USD at bet start
        uint256 startTime;
        bool resolved;
        bool won;
        uint256 payout;
    }

    // ============================================
    // EVENTS
    // ============================================

    event BetPlaced(
        bytes32 indexed betId,
        address indexed player,
        uint256 amount,
        bool direction,
        int256 startPrice,
        uint256 ethFee
    );

    event BetResolved(
        bytes32 indexed betId,
        address indexed player,
        bool won,
        int256 endPrice,
        uint256 payout,
        uint256 fee
    );

    event PoolDeposited(address indexed from, uint256 amount);
    event PoolWithdrawn(address indexed to, uint256 amount);
    event EntryFeeUpdated(uint256 newFeeUsd);
    event WinFeeUpdated(uint256 newPercent);

    // ============================================
    // MODIFIERS
    // ============================================

    modifier validWager(uint256 amount) {
        require(amount >= MIN_WAGER, "Below minimum wager");
        require(amount <= MAX_WAGER, "Above maximum wager");
        _;
    }

    modifier poolSolvency(uint256 amount) {
        uint256 available = poolBalance - lockedBalance;
        uint256 maxWager = (available * MAX_POOL_PERCENT) / 100;

        require(amount <= maxWager, "Wager too large for pool");
        require(available >= amount, "Insufficient pool liquidity");
        _;
    }

    modifier cooldownPassed() {
        require(
            block.timestamp >= lastBetTime[msg.sender] + COOLDOWN,
            "Cooldown not passed"
        );
        _;
    }

    // ============================================
    // CONSTRUCTOR
    // ============================================

    constructor(
        address _rareToken,
        address _ethUsdFeed,
        address _btcUsdFeed,
        address _treasury,
        uint256 _initialPool
    ) Ownable(msg.sender) {
        require(_rareToken != address(0), "Invalid RARE token");
        require(_ethUsdFeed != address(0), "Invalid ETH feed");
        require(_btcUsdFeed != address(0), "Invalid BTC feed");
        require(_treasury != address(0), "Invalid treasury");

        rareToken = IERC20(_rareToken);
        ethUsdFeed = AggregatorV3Interface(_ethUsdFeed);
        btcUsdFeed = AggregatorV3Interface(_btcUsdFeed);
        treasury = _treasury;

        // Initialize pool
        if (_initialPool > 0) {
            require(
                rareToken.transferFrom(msg.sender, address(this), _initialPool),
                "Pool funding failed"
            );
            poolBalance = _initialPool;
            emit PoolDeposited(msg.sender, _initialPool);
        }
    }

    // ============================================
    // CORE FUNCTIONS
    // ============================================

    /**
     * @notice Place a bet on BTC/USD direction
     * @param amount RARE tokens to wager
     * @param direction true = UP, false = DOWN
     * @return betId Unique identifier for the bet
     */
    function placeBet(
        uint256 amount,
        bool direction
    )
        external
        payable
        nonReentrant
        whenNotPaused
        validWager(amount)
        poolSolvency(amount)
        cooldownPassed
        returns (bytes32 betId)
    {
        // Calculate and verify ETH entry fee
        uint256 ethFee = calculateEthFee();
        require(msg.value >= ethFee, "Insufficient ETH fee");

        // Refund excess ETH
        if (msg.value > ethFee) {
            (bool refunded, ) = payable(msg.sender).call{value: msg.value - ethFee}("");
            require(refunded, "ETH refund failed");
        }

        // Transfer ETH fee to treasury
        (bool sent, ) = payable(treasury).call{value: ethFee}("");
        require(sent, "ETH transfer failed");

        // Transfer RARE wager to contract
        require(
            rareToken.transferFrom(msg.sender, address(this), amount),
            "RARE transfer failed"
        );

        // Get current BTC price
        int256 btcPrice = getBtcPrice();

        // Generate unique bet ID
        betId = keccak256(abi.encodePacked(
            msg.sender,
            block.timestamp,
            amount,
            direction,
            totalBets
        ));

        // Create bet
        bets[betId] = Bet({
            player: msg.sender,
            amount: amount,
            direction: direction,
            startPrice: btcPrice,
            startTime: block.timestamp,
            resolved: false,
            won: false,
            payout: 0
        });

        // Update state
        lockedBalance += amount;
        lastBetTime[msg.sender] = block.timestamp;
        activeBets[msg.sender]++;
        totalBets++;
        totalVolume += amount;

        emit BetPlaced(betId, msg.sender, amount, direction, btcPrice, ethFee);
    }

    /**
     * @notice Resolve a bet after duration has passed
     * @param betId The bet to resolve
     */
    function resolveBet(bytes32 betId) external nonReentrant {
        Bet storage bet = bets[betId];

        require(bet.player != address(0), "Bet not found");
        require(!bet.resolved, "Already resolved");
        require(block.timestamp >= bet.startTime + BET_DURATION, "Too early");

        // Get current BTC price
        int256 endPrice = getBtcPrice();

        // Determine outcome
        bool priceWentUp = endPrice > bet.startPrice;
        bool won = (priceWentUp && bet.direction) || (!priceWentUp && !bet.direction);

        bet.resolved = true;
        bet.won = won;
        bet.endPrice = endPrice; // Add to struct if needed

        // Unlock balance
        lockedBalance -= bet.amount;

        if (won) {
            // Calculate payout (original wager + profit)
            uint256 profit = bet.amount;
            uint256 fee = (profit * winFeePercent) / 100;
            uint256 payout = bet.amount + profit - fee;

            // Check pool can afford it
            require(poolBalance >= payout - bet.amount, "Pool insufficient");

            // Update pool (remove profit + fee, but add back wager since we already have it)
            poolBalance -= profit;
            poolBalance += fee; // Fee stays in pool or goes to treasury

            // Transfer fee to treasury in RARE
            if (fee > 0) {
                require(rareToken.transfer(treasury, fee), "Fee transfer failed");
                totalFeesCollected += fee;
            }

            // Transfer payout to winner
            require(rareToken.transfer(bet.player, payout), "Payout failed");

            bet.payout = payout;
            totalWins++;

            emit BetResolved(betId, bet.player, true, endPrice, payout, fee);
        } else {
            // Lost - wager stays in pool
            poolBalance += bet.amount;
            bet.payout = 0;
            totalLosses++;

            emit BetResolved(betId, bet.player, false, endPrice, 0, 0);
        }

        activeBets[bet.player]--;
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================

    /**
     * @notice Calculate ETH fee based on current oracle price
     * @return ethAmount ETH needed for entry fee
     */
    function calculateEthFee() public view returns (uint256 ethAmount) {
        (, int256 ethPrice, , , ) = ethUsdFeed.latestRoundData();
        require(ethPrice > 0, "Invalid ETH price");

        // ethAmount = usdFee * 1e18 / ethPrice
        // ethPrice is in 8 decimals, entryFeeUsd is in 18 decimals
        ethAmount = (entryFeeUsd * 1e8) / uint256(ethPrice);
    }

    /**
     * @notice Get current BTC/USD price
     * @return price Current price in 8 decimals
     */
    function getBtcPrice() public view returns (int256 price) {
        (, price, , , ) = btcUsdFeed.latestRoundData();
        require(price > 0, "Invalid BTC price");
    }

    /**
     * @notice Get max wager amount based on pool size
     * @return maxWager Maximum RARE that can be wagered
     */
    function getMaxWager() external view returns (uint256 maxWager) {
        uint256 available = poolBalance - lockedBalance;
        maxWager = (available * MAX_POOL_PERCENT) / 100;

        if (maxWager > MAX_WAGER) maxWager = MAX_WAGER;
        if (maxWager < MIN_WAGER) maxWager = 0;
    }

    /**
     * @notice Get pool statistics
     */
    function getPoolStats() external view returns (
        uint256 _poolBalance,
        uint256 _lockedBalance,
        uint256 _availableBalance,
        uint256 _maxWager
    ) {
        _poolBalance = poolBalance;
        _lockedBalance = lockedBalance;
        _availableBalance = poolBalance - lockedBalance;
        _maxWager = (_availableBalance * MAX_POOL_PERCENT) / 100;
    }

    // ============================================
    // ADMIN FUNCTIONS
    // ============================================

    /**
     * @notice Update entry fee in USD
     * @param newFeeUsd New fee in USD (18 decimals)
     */
    function setEntryFee(uint256 newFeeUsd) external onlyOwner {
        require(newFeeUsd > 0, "Fee must be > 0");
        entryFeeUsd = newFeeUsd;
        emit EntryFeeUpdated(newFeeUsd);
    }

    /**
     * @notice Update win fee percentage
     * @param newPercent New percentage (0-20)
     */
    function setWinFee(uint256 newPercent) external onlyOwner {
        require(newPercent <= 20, "Fee too high");
        winFeePercent = newPercent;
        emit WinFeeUpdated(newPercent);
    }

    /**
     * @notice Deposit RARE to pool
     * @param amount RARE to add
     */
    function depositPool(uint256 amount) external onlyOwner {
        require(rareToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        poolBalance += amount;
        emit PoolDeposited(msg.sender, amount);
    }

    /**
     * @notice Withdraw RARE from pool
     * @param amount RARE to withdraw
     * @dev Cannot withdraw locked amounts or drop below 10% of current
     */
    function withdrawPool(uint256 amount) external onlyOwner {
        uint256 available = poolBalance - lockedBalance;
        uint256 minReserve = (poolBalance * 10) / 100; // Keep 10% reserve

        require(amount <= available, "Insufficient available");
        require(available - amount >= minReserve, "Would breach reserve");

        poolBalance -= amount;
        require(rareToken.transfer(msg.sender, amount), "Transfer failed");
        emit PoolWithdrawn(msg.sender, amount);
    }

    /**
     * @notice Update treasury address
     */
    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Invalid address");
        treasury = newTreasury;
    }

    /**
     * @notice Emergency pause
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Emergency withdraw (only when paused)
     */
    function emergencyWithdraw() external onlyOwner whenPaused {
        uint256 balance = rareToken.balanceOf(address(this));
        require(rareToken.transfer(owner(), balance), "Transfer failed");
    }

    // ============================================
    // RECEIVE
    // ============================================

    receive() external payable {
        // Accept ETH for fees
    }
}
