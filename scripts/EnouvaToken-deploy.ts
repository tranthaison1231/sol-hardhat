import { ethers } from 'hardhat';

async function main() {
  const EnouvaToken = await ethers.getContractFactory('EnouvaToken');
  console.log('Deploying EnouvaToken...');
  const token = await EnouvaToken.deploy(
    '10000000000000000000000',
    ['0x00995d39AF55A0675D00b851402cFC2d070d339C'],
    ['0x00995d39AF55A0675D00b851402cFC2d070d339C'],
  );

  await token.deployed();
  console.log('EnouvaToken deployed to:', token.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
