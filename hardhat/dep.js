const hre = require("hardhat");
const ethers = hre.ethers;

async function main(){
    const Wallet = await ethers.getContractFactory("Wallet")
    const wallet = await Wallet.deploy()
    await wallet.deployed()

    console.log("Wallet address (SC): ", wallet.address)
}
//handle err
main().then(()=>process.exit(0)).catch((error) => {
    console.error(error);
    process.exit(1);
  });
//  npx hardhat run dep.js --network localhost