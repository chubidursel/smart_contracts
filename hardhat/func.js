const hre = require("hardhat")
const { ContractFunctionType } = require("hardhat/internal/hardhat-network/stack-traces/model")
const ethers = hre.ethers
//get abi of our SC
const walletArtifact = require("../artifacts/contracts/Wallet.sol/Wallet.json")

async function main(){
  const contractAdd = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
  const accAdd = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
  const guestAdd = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8'
  let signer = ethers.provider.getSigner(accAdd) // private keys
    // SET UP a CONTRACT object to interact with
  const contract = new ethers.Contract(contractAdd, walletArtifact.abi,signer)
    //SEND $$ .>> SC
  let tx = {
    to: contractAdd,
    value: ethers.utils.parseEther('10')
  }
  result = await signer.sendTransaction(tx)
  console.log(result)
  //CALL SC functions
  const scBalance = await contract.getBalance()
  console.log(ethers.utils.formatEther(scBalance))

  const ownerSC = await contract.owner(); //getter func about public var
  console.log(ownerSC)
  const addUser = await contract.addUser(guestAdd, "Bob", 10000); // add new user with 3 params
  console.log(addUser) // tx object 
  console.log(await contract.members(guestAdd)) // check maping
}

main().then(()=>process.exit(0)).catch((error) => {
    console.error(error)
    process.exit(1)
  });
//  npx hardhat run func.js --network localhost

  // //insted pun long cammand in terminal use this 
  // const url = 'http://127.0.0.1:8545/'
  // const provider = new ethers.providers.JsonRpcProvider(url)