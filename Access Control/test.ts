import { loadFixture, ethers, expect, time } from "./setup";
import type { Demo } from "../typechain-types";

describe("Demo", function() {
  async function deploy() {
    const [ superadmin, withdrawer, payer ] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Demo");
    const demo: Demo = await Factory.deploy(withdrawer.address);
    await demo.deployed();

    return { superadmin, demo, payer, withdrawer }
  }

  it('works', async function() {
    const { superadmin, demo, payer, withdrawer } = await loadFixture(deploy);

    console.log(await demo.getRoleAdmin(await demo.WITHDRAWER_ROLE()), await demo.DEFAULT_ADMIN_ROLE());

    await demo.connect(withdrawer).grantRole(await demo.PAYER_ROLE(), payer.address);
    await demo.connect(withdrawer).withdraw();
  });
});