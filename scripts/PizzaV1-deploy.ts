import { ethers, upgrades } from 'hardhat';

async function main() {
  const Pizza = await ethers.getContractFactory('Pizza');

  console.log('Deploying Pizza...');

  const pizza = await upgrades.deployProxy(Pizza, [8], {
    initializer: 'initialize',
  });
  await pizza.deployed();

  console.log('Pizza deployed to:', pizza.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
