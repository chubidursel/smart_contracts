// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Basic{

//---------------------- EXAMPLE #1 basic-------------------------------
    function setNum(uint256 newNum) public{
        assembly {
            sstore(0, newNum)
        }
    }
    function getNum() public view returns(uint256){
        assembly{
            let x := sload(0)
            mstore(0x80, x) //store temporary in memory
            return(0x80, 32)
        }
    }

//---------------------- EXAMPLE #2 FUNCTION -------------------------------
  function encrypt(string memory _input, bool _decrypt) external pure returns (string memory) {

        bytes32 output;
        
        assembly {
            function stringToBytes(a) -> b {
                b := mload(add(a, 32))
            }
            function addToBytes(bs,decrypt) -> r {
                if eq(decrypt, false) {
                    mstore(0x0, add(bs,0x0101010101010101010101010101010101010101010101010101010101010101))
                } 
                if eq(decrypt, true) {
                    mstore(0x0, sub(bs,0x0101010101010101010101010101010101010101010101010101010101010101))
                }
                r := mload(0x0)
            }
            let byteString := stringToBytes(_input)
            output := addToBytes(byteString,_decrypt)
        }
        bytes memory bytesArray = new bytes(32);
        for (uint i; i < 32; i++) bytesArray[i] = output[i];
        return string(bytesArray);
    }




//---------------------- EXAMPLE #3 -------------------------------
    function at(address addr) public view returns (bytes memory code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(addr)
            // allocate output byte array - this could also be done without assembly
            // by using code = new bytes(size)
            code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(addr, add(code, 0x20), 0, size)
        }
    }








}