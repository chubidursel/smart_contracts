//SPDX-License-Identifier: MIT    
pragma solidity ^0.8.15;

contract Wallet {
    // declare state, events and modifier
    address public owner;
    mapping(address => uint) public members; // or loke this: (add=>bool) 
    event MoneyWithdrawn(address indexed _to, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    constructor(){
        owner = msg.sender;
    }
    modifier memberLimitOrOwner(uint _amount) {
        require(owner == msg.sender || members[msg.sender] >= _amount, "You are not allowed to perform this operation!");
    _;}

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    // FUNCTIONS ABOUT MEMBER
    function addLimit(address _member, uint _limit) public {
        require(msg.sender == owner, "Yo yooo, u can't do this!");
        members[_member] = _limit;     
    }
    function deduceFromLimit(address _member, uint _amount) internal {
        members[_member] -= _amount;
    }
    // ---------- WITHDRAW ------------
    function withdrawMoney(uint _amount) public memberLimitOrOwner(_amount){
        require(_amount <= address(this).balance, "Not enough funds to withdraw!");
        if(owner != msg.sender) { 
            deduceFromLimit(msg.sender, _amount); 
        }
        address payable _to = payable(msg.sender);
        _to.transfer(_amount);
        emit MoneyWithdrawn(_to, _amount);
    }
    // ---------- GET MONEY ------------
    function sendToContract() public payable{
        address payable _to = payable(this);
        _to.transfer(msg.value);
    }
    fallback() external payable {}
    receive() external payable {emit MoneyReceived(msg.sender, msg.value);}
}

//??????quiestion
// store users as [arr] or mapping(add=>bool)?
//How to check if add in arr? 
/*
    address public owner;
    uint public money;
    uint public limit = 1000;
    mapping(address=>bool) public users;

    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
       require(msg.sender == owner, "Yo yooo, u can't do this!");
        _;
    }
    
    modifier allowUsers(){
        require(users[msg.sender], "Yo yooo, u can't do this!");
        _;
    }
    
    function setLimit(uint _limit) public onlyOwner{
        limit = _limit;
    }
    function addUser(address _add) public onlyOwner{
        users[_add] = true;
    }

    function getMoney()public payable{
        money += msg.value;
    }
    function withdrawOwner(uint _amount) public onlyOwner{
            address payable _to = payable(owner);
            _to.transfer(_amount);
            money -= _amount;
    }
    function withdrawUsers()public allowUsers{
        address payable _to = payable(msg.sender);
        _to.transfer(limit);
        money -= limit;
        users[msg.sender] = false;
    }

    othersss

    function withdraw(uint _amount)public {
        if(msg.sender == owner){
            address payable _to = payable(owner);
            _to.transfer(_amount);
            money -= _amount;
        } else if (users[msg.sender]){
            require(_amount <= limit, "Too much for you!");
            address payable _to = payable(msg.sender);
            _to.transfer(limit);
            money -= limit;
            users[msg.sender] = false;
            revert("Oi wei! problems");
        }
    }

*/