// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @dev Interface for Basenames (typically an ENS-style NFT)
 */
interface IBasenameRegistry {
    function balanceOf(address owner) external view returns (uint256);
}

/**
 * @title Rare Fountain V2
 * @notice Dual-pool distribution system with 3-Tier Proof of Humanity
 * @dev Upgraded from 0.6.x to 0.8.20.
 */
contract RareFountainV2 is ReentrancyGuard, Ownable, Pausable {

    // --- State Variables ---

    IERC20 public rareToken;
    IBasenameRegistry public basenameRegistry;
    address public stakingContract;
    address public lotteryContract;

    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public poolBalance = 100 * 10**18; 
    
    // --- Whitelist Tier Config ---
    uint256 public rareHoldingThreshold = 1000 * 10**18; // Tier 2: RARE Holding
    mapping(address => bool) public manualWhitelist;      // Tier 1: Manual Admin Auth

    bool public regPeriod = true; 
    uint256 public regIncA; 
    uint256 public regIncB; 
    uint256 public cycleCount;

    mapping(address => bool) public registeredA;
    mapping(address => bool) public registeredB;
    mapping(address => uint256) public lastRegistrationTimestamp;

    // --- Events ---

    event Registered(address indexed user, bool poolA, uint256 cycle);
    event Claimed(address indexed user, uint256 amount, uint256 cycle);
    event PoolFlipped(uint256 newCycle, bool nowPoolA);
    event ThresholdUpdated(uint256 newThreshold);
    event WhitelistUpdated(address indexed user, bool status);

    constructor(
        address _rareToken,
        address _stakingContract,
        address _lotteryContract,
        address _basenameRegistry,
        address _initialOwner
    ) Ownable(_initialOwner) {
        rareToken = IERC20(_rareToken);
        stakingContract = _stakingContract;
        lotteryContract = _lotteryContract;
        basenameRegistry = IBasenameRegistry(_basenameRegistry);
    }

    // --- External Functions ---

    /**
     * @notice Verify if a user is eligible to claim via one of the 3 whitelist methods
     * @return bool True if the user is authorized
     */
    function isEligible(address _user) public view returns (bool) {
        // Method 1: Manual Whitelist
        if (manualWhitelist[_user]) return true;

        // Method 2: RARE Token Holding (Configurable threshold)
        if (rareToken.balanceOf(_user) >= rareHoldingThreshold) return true;

        // Method 3: Base Username (Basenames)
        if (address(basenameRegistry) != address(0)) {
            if (basenameRegistry.balanceOf(_user) > 0) return true;
        }

        return false;
    }

    /**
     * @notice Register for the current active distribution pool
     * @dev Implements 24h rate limit and 3-method Whitelist verification
     */
    function register() external payable whenNotPaused nonReentrant {
        require(
            block.timestamp >= lastRegistrationTimestamp[msg.sender] + SECONDS_PER_DAY,
            "Rate limit: 24h cooldown"
        );
        
        // --- 3-Tier Proof of Humanity Check ---
        require(isEligible(msg.sender), "Not eligible: Proof of Humanity required (Manual, RARE, or Basename)");

        // Registration Logic
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
        
        if (!regPeriod) {
            require(registeredA[msg.sender], "No claim available in Pool A");
            require(regIncA > 0, "Pool A is empty");
            amount = poolBalance / regIncA;
            registeredA[msg.sender] = false;
        } else {
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
     */
    function flipPool() external whenNotPaused nonReentrant {
        regPeriod = !regPeriod;
        cycleCount++;
        
        if (regPeriod) {
            regIncA = 0;
        } else {
            regIncB = 0;
        }

        emit PoolFlipped(cycleCount, regPeriod);
    }

    // --- Admin Functions ---

    /**
     * @notice Update the RARE holding threshold (T2 Whitelist)
     */
    function setRareThreshold(uint256 _amount) external onlyOwner {
        rareHoldingThreshold = _amount;
        emit ThresholdUpdated(_amount);
    }

    /**
     * @notice Manually whitelist or remove an address (T1 Whitelist)
     */
    function setManualWhitelist(address _user, bool _status) external onlyOwner {
        manualWhitelist[_user] = _status;
        emit WhitelistUpdated(_user, _status);
    }

    function setBasenameRegistry(address _registry) external onlyOwner {
        basenameRegistry = IBasenameRegistry(_registry);
    }

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
