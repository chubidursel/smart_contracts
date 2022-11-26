// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GameItems is ERC1155, Ownable {
    
    uint256 public constant BITCOIN = 0;
    uint256 public constant ETHEREUM = 1;
    uint256 public constant MONERO = 2;
    uint256 public constant LITECOIN = 3;
    
    mapping (uint256 => string) private _uris;

    constructor() public ERC1155("ipfs://QmXkkX5yuKTCN8AzrpeDtD8vqYrZA7BkAjdEdzkeoSAd2C/{id}.png") {
        _mint(msg.sender, BITCOIN, 10, "");
        _mint(msg.sender, ETHEREUM, 30, "");
        _mint(msg.sender, MONERO, 50, "");
        _mint(msg.sender, LITECOIN, 100, "");
    }
    
    function uri(uint256 tokenId) override public view returns (string memory) {
        return(_uris[tokenId]);
    }
    
    function setTokenUri(uint256 tokenId, string memory uri) public onlyOwner {
        require(bytes(_uris[tokenId]).length == 0, "Cannot set uri twice"); 
        _uris[tokenId] = uri; 
    }
}