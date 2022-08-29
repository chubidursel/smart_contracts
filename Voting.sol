// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MCSToken is ERC20, Ownable {
    constructor() ERC20("MCS Token", "MST") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}


contract VoteFactory {
  address public owner;

  Event ContractCreate (address indexed addressContract, string description, uint durationTime);

  Vote[] public votes;
  mapping(address => bool) existingVotes;
  ERC20 public votingToken;

  constructor(ERC20 _votingToken) {
    owner = msg.sender;
    votingToken = _votingToken;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  function createVote(string calldata desc, uint duration) external onlyOwner{
    Vote newVote = new Vote(desc, duration);
    votes.push(newVote);
    existingVotes[address(newVote)] = true;

    emit ContractCreate(address(newVote), desc, duration);
  } 

  function withdraw(address receiver) external onlyOwner {
    uint currentBalance = votingToken.balanceOf(address(this));
    
    require(currentBalance > 0, "Nothing to transfer");
    
    votingToken.transfer(receiver, currentBalance);
  }
  
  function onVotingEnded() external {
    require(existingVotes[msg.sender], "Not existing voting!");
    // TODO: как лучше сообщить о статусе голосования (прошло, не прошло, не состоялось)
  }
}


contract Vote {
  VoteFactory public parent;
  string public desc;
  uint immutable endsAt;
  //mapping (address => uint8) public voteResults;
  mapping (address => bool) public isVoted;

  uint public votesFor;
  uint public votesAgainst;

  enum Result {Rejected, Accepted, Failed};
  Result public resultOfVoting;
  bool public isVotingStopped;

  address[] public voters;
  event Voted(address indexed addrVoted, bool vote);
  
  constructor(string memory _desc, uint duration) {
    parent = VoteFactory(msg.sender);
    desc = _desc;
    endsAt = block.timestamp + duration;    
  }

  function makeVote (bool _vote) public {
    require(block.timestamp < endsAt, "Too late!");
    require(!isVoted[msg.sender], "Already voted!");
    
    bool result = parent.votingToken().transferFrom(
        msg.sender,
        address(this),
        1
    );

    
    require(result, "Token tranfer failed!");
    voters.push(msg.sender);
    _vote == true ? votesFor++ : votesAgainst++;
    isVoted[msg.sender] = true; 
    
    emit Voted(msg.sender, _vote);
  }

  function setFinalResult() external {
    require(block.timestamp >= endsAt, "Too early!");
    require(isVotingStopped == false, "Voting stopped!");
    isVotingStopped = true;
    uint totalToken = parent.votingToken().totalSupply();
    uint totalVote = votesFor + votesAgainst;
    if((totalVote * 100 / totalToken) >= 4) {
      if(votesFor >= votesAgainst) {
        resultOfVoting = Result.Accepted;
      } else {
        resultOfVoting = Result.Rejected;
      }
      uint balanceOfToken = parent.votingToken().balanceOf(address(this));
      parent.votingToken().transfer(address(parent), balanceOfToken);
    } else {
      resultOfVoting = Result.Failed;
      for(uint i; i<voters.length; i++) {
        parent.votingToken().transfer(voters[i], 1);
      }
    }
    parent.onVotingEnded(resultOfVoting);
  }
  
  //todo 
}

