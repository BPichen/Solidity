import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.4.18"
      },
      {
        version: "0.4.23"
      },
      {
        version: "0.5.16",
      },
      {
        version: "0.6.6",
      },
      {
        version: "0.8.12"
      },
      {
        version: "0.8.18"
      }
    ],
  },
  networks: {
    hardhat: {
      accounts: {
        count: 20
      },
      forking: {
        url: "https://eth.llamarpc.com"
      }
    }
  }
};
export default config;
