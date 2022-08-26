import 'dotenv/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-etherscan';

const metamask_private_key = `0x${process.env.METAMASK_PRIVATE_KEY}`;

const config = {
  solidity: '0.8.16',
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
    apiKey: {
      rinkeby: String(process.env.ETHERSCAN_API_KEY),
    },
  },
};

export default config;
