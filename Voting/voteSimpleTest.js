import { loadFixture, ethers, expect, time } from "./setup";
import type { Voter } from "../typechain-types";
import type { Signer } from 'ethers';

describe("Voter", function() {
  async function deploy() {
    const [ c1, c2, c3, v1, v2, v3, v4, v5 ] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Voter");
    const voter: Voter = await Factory.deploy();
    await voter.deployed();

    return { voter, c1, c2, c3, v1, v2, v3, v4, v5 }
  }

  async function addCandidate(voter: Voter, acc: Signer, votingId = 0) {
    const tx = await voter.connect(acc).addCandidate(votingId);
    await tx.wait();
  }

  async function voteFor(voter: Voter, acc: Signer, candidate: string, votingId = 0) {
    const tx = await voter.connect(acc).vote(votingId, candidate);
    await tx.wait();
  }

  it('works', async function() {
    const { voter, c1, c2, c3, v1, v2, v3, v4, v5 } = await loadFixture(deploy);

    const addTx = await voter.addVoting();
    await addTx.wait();

    await addCandidate(voter, c1);
    await addCandidate(voter, c2);
    await addCandidate(voter, c3);

    await time.increase(121);

    await voter.startVoting(0);

    await voteFor(voter, v1, c1.address);
    await voteFor(voter, v2, c3.address);
    await voteFor(voter, v3, c1.address);
    await voteFor(voter, v4, c2.address);
    //await voteFor(voter, v5, c2.address);

    await time.increase(121);

    const winners = await voter.winners(0);

    expect(winners).to.include.members([c1.address]);
    expect(winners.length).to.eq(1);
    expect(winners).not.to.include.members([c3.address]);
  });
});