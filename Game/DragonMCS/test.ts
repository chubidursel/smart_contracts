


import { loadFixture, ethers, expect, time, anyValue } from "./setup";
import type { Game } from "../typechain-types";
import type { Signer, ContractReceipt, BigNumberish } from 'ethers';
import { MinEthersFactory } from "../typechain-types/common";

describe("Game", function() {
  const settings: Game.SettingsStruct = {
    dragonHp: 20,
    dragonMinDmg: 0,
    dragonMaxDmg: 9,
    playerHp: 15,
    playerMinDmg: 1,
    playerMaxDmg: 7,
    potionHealAmount: 4,
    playerPotions: 2,
  }

  async function deploy(overrideSettings = {}, bet = '1.0') {
    const [ owner, player ] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory('Game');
    const game: Game = await Factory.deploy({
      ...settings,
      ...overrideSettings
    }, {value: ethers.utils.parseUnits(bet, 'ether')});

    await game.deployed();

    return { game, owner, player }
  }

  async function setPlayer(game: Game, player: Signer, bet = undefined) {
    return game.connect(player).start({value: bet ?? await game.BET()});
  }

  async function makeTurn(game: Game, player: Signer) {
    return game.connect(player).turn();
  }

  async function eventFor(receipt: ContractReceipt, name: string) {
    return receipt?.events?.find(function (e) {
      return e.event === name;
    });
  }

  function validateDmgs(playerDmg: BigNumberish, dragonDmg: BigNumberish | undefined) {
    expect(playerDmg).to.be.lessThanOrEqual(settings.playerMaxDmg).and.be.greaterThanOrEqual(settings.playerMinDmg);
    if(dragonDmg !== undefined) {
      expect(dragonDmg).to.be.lessThanOrEqual(settings.dragonMaxDmg).and.be.greaterThanOrEqual(settings.dragonMinDmg);
    }
  }

  describe("constructor", function() {
    it("should not allow to set hp < 1", async function() {
      await expect(deploy({dragonHp: 0})).to.be.revertedWith("dragon HP must be > 0");
    });

    it("should not be possible to deploy without bet", async function() {
      await expect(deploy({}, "0.0")).to.be.revertedWith("invalid bet");
    });

    it("should allow to deploy with valid settings", async function() {
      const { game } = await loadFixture(deploy);

      expect(await game.playerHp()).to.eq(settings.playerHp);
    });
  });

  describe("start", function() {
    it("can be called when no player is set", async function() {
      const { game, player } = await loadFixture(deploy);

      const tx = await setPlayer(game, player);
      await tx.wait();

      expect(await game.player()).to.eq(player.address);
      expect(tx).to.emit(game, "GameStarted").withArgs(player.address, ethers.utils.parseUnits("2.0", "ether"));

      await expect(setPlayer(game, player)).to.be.revertedWith("player set");
    });
  });

  describe("turn", function() {
    it("results in player and dragon attacks", async function() {
      const { game, player } = await loadFixture(deploy);

      const tx = await setPlayer(game, player);
      await tx.wait();

      const txTurn = await makeTurn(game, player);
      const receipt = await txTurn.wait();
      const playerEvent = await eventFor(receipt, "PlayerHit");
      const playerDmg = playerEvent?.args?.dmg;
      const dragonEvent = await eventFor(receipt, "DragonHit");
      const dragonDmg = dragonEvent?.args?.dmg;

      validateDmgs(playerDmg, dragonDmg);

      // await expect(txTurn).to.emit(game, "PlayerHit").withArgs(playerDmg);//(anyValue);
      // await expect(txTurn).to.emit(game, "DragonHit").withArgs(anyValue);
      expect(await game.playerHp()).to.be.lessThanOrEqual(settings.playerHp);
      expect(await game.dragonHp()).to.be.lessThan(settings.dragonHp);
      expect(await game.finished()).to.be.false;
      await expect(game.withdraw()).to.be.revertedWith("game is not finished yet");
    });

    it("ends the game when the player loses", async function() {
      const { game, player } = await deploy({playerHp: 1, dragonMinDmg: 1});

      const tx = await setPlayer(game, player);
      await tx.wait();

      const initialBalance = await game.getBalance();

      const txTurn = await makeTurn(game, player);
      const receipt = await txTurn.wait();

      const playerEvent = await eventFor(receipt, "PlayerHit");
      const playerDmg = playerEvent?.args?.dmg;
      const dragonEvent = await eventFor(receipt, "DragonHit");
      const dragonDmg = dragonEvent?.args?.dmg;

      validateDmgs(playerDmg, dragonDmg);

      expect(await game.dragonHp()).to.be.greaterThan(0);
      expect(
        (await game.playerHp()).sub(ethers.BigNumber.from(dragonDmg))
      ).to.be.lessThanOrEqual(0);

      await expect(txTurn).to.emit(game, "DragonWon").withArgs(anyValue);
      expect(await game.finished()).to.be.true;
      expect(await game.getBalance()).to.eq(initialBalance);
      await expect(makeTurn(game, player)).to.be.rejectedWith("game is finished");
    });

    it("ends the game and pays prize when the player wins", async function() {
      const { game, player } = await deploy({dragonHp: 1});

      const tx = await setPlayer(game, player);
      await tx.wait();

      const initialBalance = await game.getBalance();

      const txTurn = await makeTurn(game, player);
      const receipt = await txTurn.wait();

      await expect(txTurn).not.to.emit(game, "DragonHit");

      const playerEvent = await eventFor(receipt, "PlayerHit");
      const playerDmg = playerEvent?.args?.dmg;

      validateDmgs(playerDmg, undefined);

      expect(await game.playerHp()).to.be.greaterThan(0);
      expect(
        (await game.dragonHp()).sub(ethers.BigNumber.from(playerDmg))
      ).to.be.lessThanOrEqual(0);

      await expect(txTurn).to.emit(game, "PlayerWon").withArgs(anyValue);
      await expect(txTurn).to.changeEtherBalance(player, initialBalance);
      expect(await game.finished()).to.be.true;
    });
  });
});