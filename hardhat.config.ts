import 'dotenv/config';
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

const metamask_private_key = '0x' + process.env.METAMASK_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: '0.8.9',
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    hardhat: {},
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.PROJECT_ID}`,
      accounts: [metamask_private_key],
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.PROJECT_ID}`,
      accounts: [metamask_private_key],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
