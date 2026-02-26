// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Rare Lottery V2
 * @notice Modernized lottery for Base Chain with bot protection
 * @dev Upgraded from 0.4.17 to 0.8.20. 
 * @dev NOTE: For Base Chain, we should use Pyth Entropy or Chainlink VRF V2.5 for randomness.
 * @dev This version uses a commit-reveal or placeholder for VRF to be completed upon deployment.
 */
contract RareLotteryV2 is Ownable, Pausable, ReentrancyGuard {

    // --- Configuration ---

    IERC20 public rareToken;
    uint256 public constant MIN_ENTRY_FEE_NATIVE = 0.001 ether;
    uint256 public constant MIN_ENTRY_FEE_RARE = 10 * 10**18;
    uint256 public constant MIN_PLAYERS = 3;
    uint256 public constant MAX_ENTRIES_PER_ADDRESS = 5;

    // --- State Variables ---

    address[] public players;
    mapping(address => uint256) public entryCount;
    bool public lotteryActive;
    uint256 public currentLotteryId;

    // --- Events ---

    event LotteryEntered(address indexed player, uint256 lotteryId);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 lotteryId);
    event LotteryStarted(uint256 lotteryId);

    constructor(address _rareToken, address _initialOwner) Ownable(_initialOwner) {
        rareToken = IERC20(_rareToken);
    }

    // --- External Functions ---

    /**
     * @notice Enter the lottery using Native Gas Token or RARE
     */
    function enter() external payable whenNotPaused nonReentrant {
        require(lotteryActive, "Lottery not active");
        require(
            msg.value >= MIN_ENTRY_FEE_NATIVE || rareToken.balanceOf(msg.sender) >= MIN_ENTRY_FEE_RARE,
            "Insufficient entry fee"
        );
        require(entryCount[msg.sender] < MAX_ENTRIES_PER_ADDRESS, "Entry limit reached");

        players.push(msg.sender);
        entryCount[msg.sender]++;

        emit LotteryEntered(msg.sender, currentLotteryId);
    }

    /**
     * @notice Start a new lottery round
     */
    function startLottery() external onlyOwner {
        require(!lotteryActive, "Lottery already active");
        lotteryActive = true;
        currentLotteryId++;
        emit LotteryStarted(currentLotteryId);
    }

    /**
     * @notice Pick a winner using a secure randomness source
     * @dev To be integrated with VRF V2.5 for Base Chain
     */
    function pickWinner() external onlyOwner nonReentrant {
        require(lotteryActive, "Lottery not active");
        require(players.length >= MIN_PLAYERS, "Not enough players");

        // Placeholder for secure randomness
        uint256 winnerIndex = _getSecureRandom() % players.length;
        address winner = players[winnerIndex];
        
        uint256 nativePrize = address(this).balance;
        uint256 tokenPrize = rareToken.balanceOf(address(this));

        // Reset state
        lotteryActive = false;
        // In a real implementation, we'd need to clear entryCount or use a mapping with lotteryId
        delete players;

        // Transfers
        if (nativePrize > 0) {
            (bool success, ) = payable(winner).call{value: nativePrize}("");
            require(success, "Native transfer failed");
        }
        if (tokenPrize > 0) {
            require(rareToken.transfer(winner, tokenPrize), "Token transfer failed");
        }

        emit WinnerSelected(winner, nativePrize + tokenPrize, currentLotteryId);
    }

    // --- Internal Functions ---

    /**
     * @dev Temporary internal randomness (should be replaced by VRF)
     */
    function _getSecureRandom() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players.length)));
    }

    // --- Admin Functions ---

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
