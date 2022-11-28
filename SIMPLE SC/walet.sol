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
