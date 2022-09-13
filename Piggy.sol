// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

//import "@openzeppelin/contracts/access/Ownable.sol";

contract Master {
    
    mapping(address => address[]) public factoryToPiggyBanks; // factorySC => [all piggyBans this type]

    mapping(address => bool) public allowedContractsList; //sc which can add new PiggyBanks to map above

    function allowedToAddNewBank(address _addr) internal view returns(bool){
        return allowedContractsList[_addr]; //check if msg.sender can add any Pigybank
    }

    function registerNewFactory(address _add) external { 
        allowedContractsList[_add] = true; // OnlyOwner??? should connect new Factory?
    }

// func which will call from factory SC
    function addPiggy(address _addr) public {
        require(allowedToAddNewBank(msg.sender), "You can't add any PiggyBanks, only verified Factory!");
        factoryToPiggyBanks[msg.sender].push(_addr);
    }
}

contract TimePiggyBankFactory {
    mapping(address => address[]) private addressToPiggyBanks; // local map with owner
    
    Master master; //<<<<<<
    
    function createTimePiggyBank(address _owner, string memory _desc, uint64 _endTime) public {
        address newTimePiggyBank = address(new TimePiggyBank(_owner, _desc, _endTime));

        master.addPiggy(newTimePiggyBank); //<<<<<< 

        addressToPiggyBanks[_owner].push(newTimePiggyBank); // push new Piggy to local map

    }

    function getPiggyBanksByAddress(address _address) public view returns (address[] memory) {
        return addressToPiggyBanks[_address];
    }
}


abstract contract PiggyBank {
    address public owner;
    bool public isOver;
    string public desc;

    constructor(address _owner, string memory _desc) {
        owner = _owner;
        desc = _desc;
    }

    function deposit() public payable {
        require(!isOver, "This piggy bank in over!");
    }

    function withdraw() public {
        require(msg.sender == owner, "You are not an owner!");
        require(isWithdrawAvailable(), "You can't do withdraw yet");
        payable(owner).transfer(address(this).balance);
        isOver = true;
    }

    function isWithdrawAvailable() public view virtual returns (bool) {}
}

contract TimePiggyBank is PiggyBank {
    uint64 public endTime;

    constructor(address _owner, string memory _desc, uint64 _endTime) PiggyBank(_owner, _desc) {
        endTime = _endTime;
    }

    function isWithdrawAvailable() public view override returns (bool) {
        return endTime < block.timestamp;
    }
}

contract AmmountPiggyBank is PiggyBank {
    uint256 public targetAmmount;

    constructor(
        address _owner,
        string memory _desc,
        uint256 _targetAmmount
    ) PiggyBank(_owner, _desc) {
        targetAmmount = _targetAmmount;
    }

    function isWithdrawAvailable() public view override returns (bool) {
        return targetAmmount < address(this).balance;
    }
}