// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Game {
    struct Settings {
        uint dragonHp;
        uint dragonMinDmg;
        uint dragonMaxDmg;
        uint playerHp;
        uint playerMinDmg;
        uint playerMaxDmg;
        uint potionHealAmount;
        uint playerPotions;
    }

    uint public dragonHp;
    uint public immutable dragonMinDmg;
    uint public immutable dragonMaxDmg;

    uint public playerHp;
    uint public immutable playerMinDmg;
    uint public immutable playerMaxDmg;
    uint public playerPotions;

    uint public immutable potionHealAmount;
    uint public constant BET = 1 ether;
    
    address public player;
    address public owner;

    bool public finished;

    event GameStarted(address indexed player, uint prize);
    event PlayerHit(uint dmg);
    event PlayerWon(uint playerHp);
    event DragonWon(uint dragonHp);
    event DragonHit(uint dmg);

    modifier whenFinished() {
        require(finished, "game is not finished yet");
        _;
    }

    modifier whenNotFinished() {
        require(!finished, "game is finished");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    modifier onlyPlayer() {
        require(msg.sender == player, "not a player");
        _;
    }

    constructor(Settings memory settings) payable {
        require(msg.value == BET, "invalid bet");
        require(settings.dragonHp > 0, "dragon HP must be > 0");
        require(settings.playerHp > 0, "player HP must be > 0");

        owner = msg.sender;

        playerHp = settings.playerHp;
        playerMinDmg = settings.playerMinDmg;
        playerMaxDmg = settings.playerMaxDmg;
        playerPotions = settings.playerPotions;
        potionHealAmount = settings.potionHealAmount;

        dragonHp = settings.dragonHp;
        dragonMinDmg = settings.dragonMinDmg;
        dragonMaxDmg = settings.dragonMaxDmg;
    }

    function start() external payable whenNotFinished {
        require(player == address(0), "player set");
        require(msg.value == BET, "wrong bet");

        player = msg.sender;

        emit GameStarted(player, getBalance());
    }

    function turn() external whenNotFinished onlyPlayer {
        uint rand = getRandomNumber(uint(uint160(msg.sender)));
        uint playerDmg = scale(rand, playerMinDmg, playerMaxDmg);

        emit PlayerHit(playerDmg);

        if(playerDmg >= dragonHp) {
            finished = true;
            payable(player).transfer(getBalance());

            emit PlayerWon(playerHp);
        } else {
            dragonHp -= playerDmg;
            dragonTurn();
        }
    }

    function dragonTurn() private {
        uint rand = getRandomNumber(uint(uint160(address(this))));
        uint dragonDmg = scale(rand, dragonMinDmg, dragonMaxDmg);

        emit DragonHit(dragonDmg);

        if(dragonDmg >= playerHp) {
            finished = true;

            emit DragonWon(dragonHp);
        } else {
            playerHp -= dragonDmg;
        }
    }

    function withdraw() external onlyOwner whenFinished {
        payable(owner).transfer(getBalance());
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function scale(uint _seed, uint _min, uint _max) private pure returns(uint) {
        uint scaled = _seed / (type(uint).max / ((_max + 1) - _min));
        return scaled + _min;
    }

    function getRandomNumber(uint _salt) private view returns(uint) {
        return uint(
            keccak256(
                abi.encodePacked(
                    _salt,
                    blockhash(block.number - 1),
                    blockhash(block.number - 2),
                    blockhash(block.number - 3)
                )
            )
        );
    }
}



