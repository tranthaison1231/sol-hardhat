import { ethers } from 'hardhat';

async function main() {
  const GetPriceFeed = await ethers.getContractFactory('GetPriceFeed');
  const contract = await GetPriceFeed.deploy();
  await contract.deployed();
  console.log('Contract deployed to:', contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
