// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


 /*
 NFT whitelisting is a way to reward your community's active users, 
 and an effective tool to prevent fraud. Instead of storing all users' data on-chain 
 (which is expensive), we can generate a Merkle tree from the users' data. 
 From the tree, we extract and store only the tree's root (bytes32) on-chain. 
 It will save a ton of gas fees!
  */
// https://dev.to/peterblockman/understand-merkle-tree-by-making-a-nft-minting-whitelist-1148

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract ExcitedApeYachtClub is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public merkleRoot;

    constructor(bytes32 merkleRoot_) ERC721('Excited Ape Yacht Club', 'EAYC') {
        merkleRoot = merkleRoot_;
    }

    function mint(uint256 quantity, bytes32[] calldata merkleProof) public {
        bytes32 node = keccak256(abi.encodePacked(msg.sender, quantity));

        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'invalid proof');

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _tokenIds.current();
            _mint(msg.sender, tokenId);

            _tokenIds.increment();
        }
    }



// ----------------------- EXAMPLE 2 ----------------
// https://etherscan.io/address/0x209e639a0ec166ac7a1a4ba41968fa967db30221#code


  bytes32 public merkleRoot; // < set up in constructor

  function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!whitelistClaimed[_msgSender()], 'Address already claimed!');
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

    whitelistClaimed[_msgSender()] = true;
    _safeMint(_msgSender(), _mintAmount);
  }
