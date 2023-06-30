import { expect } from "chai";
import { ethers } from "hardhat";


describe("Basic Contract Reading:", function () {

  it("Load WETH:", async function () {
    const wethAddress = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
    const weth = await ethers.getContractAt("WETH", wethAddress);
  });

  it("Load Uniswap Router:", async function () {
    const routerAddress = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ';
    const router = await ethers.getContractAt("UniswapV2Router02", routerAddress);
  });

  it("Deploy Test ERC20", async function () {
    const ERC20 = await ethers.getContractFactory("TestErc20");
    const erc20 = await ERC20.deploy();

    console.log(erc20);
  })

  /*it("Deploy Uniswap Factory :", async function () {
    const UNISWAPFACTORY = await ethers.getContractFactory("UniswapV2Factory");
    const uniswapFactory = await UNISWAPFACTORY.deploy();
    console.log(uniswapFactory)
});

  /*it("Deploy UniswapV2 Router", async function () {
    const Contract = await ethers.getContractFactory("UniswapV2Router02");
    const contract = await Contract.deploy();
    

    console.log(contract);
  })*/
});
