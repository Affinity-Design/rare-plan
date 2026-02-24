// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Rare Token v2
 * @notice Migrated Rare Coin token with 3,650,000 supply
 * @dev Upgraded from Solidity 0.6.x to 0.8.20
 */
contract RareTokenV2 is ERC20, Ownable {
    
    // Constants
    uint256 public constant TOTAL_SUPPLY = 3_650_000 * 10**18; // 3,650,000 RARE
    
    // Migration state
    bytes32 public merkleRoot;
    mapping(address => bool) public hasClaimed;
    uint256 public totalClaimed;
    
    // Events
    event AirdropClaimed(address indexed claimant, uint256 amount);
    event MerkleRootUpdated(bytes32 newRoot);
    
    constructor(
        address _fountainAddress,
        address _initialOwner
    ) ERC20("Rare Coin", "RARE") Ownable(_initialOwner) {
        // Mint total supply to deployer for distribution
        _mint(msg.sender, TOTAL_SUPPLY);
        
        // Transfer initial allocation to fountain for distribution
        // This will be managed by the migration process
    }
    
    /**
     * @notice Set merkle root for airdrop claims
     * @param _merkleRoot Root of merkle tree containing old holder balances
     */
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
        emit MerkleRootUpdated(_merkleRoot);
    }
    
    /**
     * @notice Claim airdrop tokens from old chain
     * @param _amount Amount of tokens to claim (100x old balance)
     * @param _proof Merkle proof validating the claim
     */
    function claimAirdrop(
        uint256 _amount,
        bytes32[] calldata _proof
    ) external {
        require(merkleRoot != bytes32(0), "Merkle root not set");
        require(!hasClaimed[msg.sender], "Already claimed");
        require(_verifyProof(_proof, msg.sender, _amount), "Invalid proof");
        
        hasClaimed[msg.sender] = true;
        totalClaimed += _amount;
        
        _transfer(owner(), msg.sender, _amount);
        
        emit AirdropClaimed(msg.sender, _amount);
    }
    
    /**
     * @notice Verify merkle proof
     * @param _proof Merkle proof
     * @param _claimant Address claiming
     * @param _amount Amount claiming
     */
    function _verifyProof(
        bytes32[] calldata _proof,
        address _claimant,
        uint256 _amount
    ) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_claimant, _amount));
        return MerkleProof.verify(_proof, merkleRoot, leaf);
    }
    
    /**
     * @notice Get remaining unclaimed tokens
     */
    function unclaimedBalance() external view returns (uint256) {
        return balanceOf(owner()) - (TOTAL_SUPPLY - totalClaimed);
    }
}

/**
 * @title MerkleProof library
 * @notice Verify merkle proofs
 */
library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        
        return computedHash == root;
    }
}
