const { ethers } = require("hardhat");

const [owner, otherAcc] = await ethers.getSigners()
const Demo = await ethers.getContractFactory("Demo", owner)
const demo = await Demo.deploy()
await demo.deploy


// USE command prompt (cuz BAsh doesn't work)
//npx hardhat clean && npx hardhat compile && npx hardhat console

// > demo   \\ check out our smart contract
// let result = await demo.run()      [demo<sc run<func from there]
// let b = await result.wait()
// b
// demo.address (?)
// b.events     (?) Check out events
// demo.on("WorkDone", (sender, at, result) =>{console.log(sender, at, result)})
//await demo.queryFilter("WorkDone") (?)Find this event
//await demo.queryFilter("WorkDone", -100) (?)last 100 blocks