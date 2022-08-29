// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

abstract contract Vote {
    address public owner;
    string[] public personArray;
    uint public endTime;
     
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(owner == msg.sender, "You are not an owner... Get out!");
        _;
    }

    struct candidate {
        bool exists;
        uint256 up;
        uint256 down;
        mapping(address => bool) Voters;
    }
    event Voted (
        uint256 up,
        uint256 down,
        address voter,
        string ticker
    );
    mapping(string => candidate) private Candidates; 

    function addCandidate(string memory _name) public onlyOwner {
        candidate storage newCandidate = Candidates[_name];
        newCandidate.exists = true;
        personArray.push(_name);
    }

    function vote(string memory _name, bool _vote) public {
        require(Candidates[_name].exists, "Can't vote for this person");
        require(!Candidates[_name].Voters[msg.sender], "You have already voted for this person");
        require(votingOver(), "You cant vote anymore");
    
        candidate storage t = Candidates[_name];
        t.Voters[msg.sender] = true;

        if(_vote){
            t.up++;
        } else {
            t.down++;
        }

        emit Voted (t.up,t.down,msg.sender,_name);
    }

    function getVotes(string memory _name) public view returns (
        uint256 up,
        uint256 down
    ){
        require(Candidates[_name].exists, "No such Candidate Defined");
        candidate storage t = Candidates[_name];
        return(t.up,t.down);
    }
    function votingOver()public view virtual returns(bool){}
}

//>>>>>>>>>>>>>>>>  TYPE #1   <<<<<<<<<<<<<<<<<
contract VoteTime is Vote{
    function setEndTime(uint _date) public {
        endTime = _date;
    }
    function votingOver()public view override returns(bool){
        return endTime < block.timestamp;
    }
}
//>>>>>>>>>>>>>>>>  TYPE #2   <<<<<<<<<<<<<<<<<
contract VoteAmount is Vote{

    uint public amount;

    function setAmount(uint _amount) public onlyOwner{
        amount = _amount;
    }

    function votingOver()public view override returns(bool){
        //check out if someone get enough votes to finish this election
        return endTime < block.timestamp;
    }
}


//>>>>>>>>>>>>>>>>  SC CREATOR   <<<<<<<<<<<<<<<<<
contract ElectionFactory{

    mapping(address =>address[]) private addressToVotes;

    function createVoteTime() public returns(address){

        address newVoteTime = address(new VoteTime());
        addressToVotes[msg.sender].push(newVoteTime);
        return newVoteTime;
    }

    // Vote[] public candidates;
    // function create() public{
    //     Vote candidate = new Vote();
    //     candidates.push(candidate);
    // }
}
