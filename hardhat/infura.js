const {ethers} = require('ethers')

const provider = new ethers.providers.JsonRpcProvider('https://goerli.infura.io/v3/4a8902a14dd842da85ed35ff2211fff5')

// const address = "0x49377441951437bee356d7d90a16dff97c66fbb0"
// const addressContract = '0xCA7384815D65bDf058382330B3e3848553597980'
// const blockNum = 7464601

const main = async() =>{

   const data = await provider.getBlockNumber()
    console.log(data)

}
main()