// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// https://jeancvllr.medium.com/solidity-tutorial-all-about-assembly-5acdfefde05c

contract gasSave{

    function addAssembly(uint x, uint y) public pure returns (uint) {
     assembly {
         let result := add(x, y)
         mstore(0x0, result)
         return(0x0, 32)
     }
    }
 
    function addSolidity(uint x, uint y) public pure returns (uint) {
        return x + y;
    }
}