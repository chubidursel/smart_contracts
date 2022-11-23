// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

contract StringComparison  { 

function comareStr(string calldata a, string calldata b) public pure returns (bool) {
    if(bytes(a).length != bytes(b).length) {
        return false;
    } else {
      return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
}

// useful website 
// https://fravoll.github.io/solidity-patterns/

