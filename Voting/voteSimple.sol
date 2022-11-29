// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Voter {
    enum Status { Empty, Created, Ongoing, Finished }

    struct Voting {
      address[] candidates;
      mapping(address => bool) isCandidate;
      mapping(address => uint) votesCount;
      address[] voters;
      mapping(address => address) voterChoices;
      Status status;
      uint startsAt;
      uint endsAt;
    }

    mapping(uint => Voting) public votings;
    uint private currentVotingId;

    uint private constant VOTING_DURATION = 120;
    uint private constant CANDIDATE_ADD_DURATION = 120;

    function addVoting() external {
        votings[currentVotingId].startsAt = block.timestamp + CANDIDATE_ADD_DURATION;
        votings[currentVotingId].status = Status.Created;
        currentVotingId++;
    }

    function addCandidate(uint _votingId) external {
        Voting storage cVoting = votings[_votingId];
        require(cVoting.status == Status.Created);
        require(cVoting.startsAt > block.timestamp);
        require(!cVoting.isCandidate[msg.sender]);

        cVoting.isCandidate[msg.sender] = true;
        cVoting.candidates.push(msg.sender);
    }

    function startVoting(uint _votingId) external {
        Voting storage cVoting = votings[_votingId];
        require(cVoting.status == Status.Created);
        require(cVoting.startsAt <= block.timestamp);

        votings[_votingId].status = Status.Ongoing;
        votings[_votingId].endsAt = block.timestamp + VOTING_DURATION;
    }

    function vote(uint _votingId, address _candidate) external {
        Voting storage cVoting = votings[_votingId];
        require(cVoting.status == Status.Ongoing);
        require(cVoting.endsAt > block.timestamp);
        require(cVoting.isCandidate[_candidate]);
        require(cVoting.voterChoices[msg.sender] == address(0));

        cVoting.voterChoices[msg.sender] = _candidate;
        cVoting.votesCount[_candidate]++;
        cVoting.voters.push(msg.sender);
    }

    function endVoting(uint _votingId) external {
        Voting storage cVoting = votings[_votingId];
        require(cVoting.status == Status.Ongoing);
        require(cVoting.endsAt <= block.timestamp);
        votings[_votingId].status = Status.Finished;
    }

    function winners(uint _votingId) external view returns(address[] memory) {
        Voting storage cVoting = votings[_votingId];

        uint candidatesCount = cVoting.candidates.length;
        uint winnersCount = 0;
        uint maximumVotes = 0;
        address[] memory localWinners = new address[](candidatesCount);
        
        for(uint i = 0; i < candidatesCount; i++) {
            address nextCandidate = cVoting.candidates[i];

            if(cVoting.votesCount[nextCandidate] == maximumVotes) {
                winnersCount += 1;
                localWinners[winnersCount - 1] = nextCandidate;
            }

            if(cVoting.votesCount[nextCandidate] > maximumVotes) {
                maximumVotes = cVoting.votesCount[nextCandidate];
                winnersCount = 1;
                localWinners[0] = nextCandidate;
            }
        }

        address[] memory allWinners = new address[](winnersCount);

        for(uint i = 0; i < winnersCount; i++) {
            allWinners[i] = localWinners[i];
        }

        return allWinners;
    }

    function votesCount(uint _votingId, address _candidate) public view returns(uint) {
        Voting storage cVoting = votings[_votingId];
        return cVoting.votesCount[_candidate];
    }   
}
