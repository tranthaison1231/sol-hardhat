import { ethers } from 'hardhat';

async function main() {
  const BadgeToken = await ethers.getContractFactory('BadgeToken');
  console.log('Deploying BadgeToken ERC721 token...');
  const token = await BadgeToken.deploy('BadgeToken', 'Badge');

  await token.deployed();
  console.log('BadgeToken deployed to:', token.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

// fromWei = ethers.utils.formatEther;
// toWei = ethers.utils.parseEther;

// const address = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
// const token = await ethers.getContractAt('GLDToken', address);

// const accounts = await hre.ethers.getSigners();
// owner = accounts[0].address;
// toAddress = accounts[1].address;

// await token.symbol();
// //'GLD'

// totalSupply = await token.totalSupply();
// fromWei(totalSupply);
