import { expect } from "chai";
import { ethers } from "hardhat";


describe("", function () {

  it("\nTest case:", async function () {

    try {
      const signers = await ethers.getSigners();
      const dead = '0x000000000000000000000000000000000000dEaD';
      const marketingWallet = '0xd53d425AdccA8350133Fd2476C8BB8cf2294b305';

      const routerAddress = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
      const router = await ethers.getContractAt("UniswapV2Router02", routerAddress);

      const TROLLV2 = await ethers.getContractFactory("TestErc20");
      const trollV2 = await TROLLV2.deploy();

      const trollV2PairAddress = await trollV2.uniswapV2Pair();
      const trollV2Address = trollV2.target;
      const trollV2Supply = await trollV2.totalSupply();
      const trollV2Decimals = await trollV2.decimals();

      const wethAddress = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
      const weth = await ethers.getContractAt("WETH", wethAddress);

      const trollV2Pair = await ethers.getContractAt("UniswapV2ERC20", trollV2PairAddress);

      /****************************************************************************** */

      var deadline = Date.now() / 1000 + 60 + 10;
      const ethToLP = ethers.parseEther("150");

      await trollV2.approve(routerAddress, ethers.MaxUint256);

      var trollV2TokenBalance = await trollV2.balanceOf(signers[0].address);
      var lpBalance = await trollV2Pair.balanceOf(signers[0].address);

      const trollV2TokensForLP = BigInt(trollV2Supply * BigInt(20) / BigInt(100));

      await router.addLiquidityETH(
        trollV2Address,
        trollV2TokensForLP,
        0,
        0,
        signers[0].address,
        deadline.toFixed().toString(),
        {
          value: ethToLP
        }
      );

      trollV2TokenBalance = await trollV2.balanceOf(signers[0].address);
      lpBalance = await trollV2Pair.balanceOf(signers[0].address);

      await trollV2Pair.transfer(dead, lpBalance);

      var tx = await trollV2.transfer(dead, trollV2TokenBalance);

      trollV2TokenBalance = await trollV2.balanceOf(signers[0].address);

      await trollV2.openTrading();
      await trollV2.transferOwnership(signers[1].address);

      for (let x = 1; x < signers.length; x++) {

        try {
          /*Buy tokens*/

          console.log(`*******************************Buy/Sell Wallet: ${x}*******************************`);

          var precision = 100;
          var randomNum = Math.floor(Math.random() * (10 * precision - 1 * precision) + 1 * precision) / (1 * precision);
          console.log(randomNum);
          const buy = {
            min: 0,
            eth: ethers.parseEther(randomNum.toString()),
            path: [wethAddress, trollV2Address],
            to: signers[x].address,
            deadline: (Date.now() / 1000 + 60 + 10).toFixed().toString()
          }

          await router.swapExactETHForTokens(
            buy.min,
            buy.path,
            buy.to,
            buy.deadline,
            {
              value: buy.eth
            }
          )
          console.log("Buy:")
          trollV2TokenBalance = await trollV2.balanceOf(signers[x].address);
          console.log(`Wallet balance: ${Number(trollV2TokenBalance) / 10 ** 9}`);
          let trollV2ContractBalanceBefore = await trollV2.balanceOf(trollV2Address);
          console.log(`Contract balance: ${Number(trollV2ContractBalanceBefore) / 10 ** 9}`);
          let trollV2MarketingWalletBalance = await ethers.provider.getBalance(marketingWallet);
          console.log(`Marketing wallet balance: ${Number(trollV2MarketingWalletBalance) / 10 ** 18}\n`);

          /*Sell tokens*/

          /*trollV2TokenBalance = await trollV2.balanceOf(signers[x].address);

          const sell = {
            amountIn: trollV2TokenBalance,
            path: [trollV2Address, wethAddress],
            to: signers[x].address,
            deadline: (Date.now() / 1000 + 60 + 10).toFixed().toString()
          }

          //let amountsOut = await router.getAmountOut(sell.amountIn, path);

          await router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            sell.amountIn,
            0,
            sell.path,
            sell.to,
            sell.deadline
          );

          console.log("Sell:")
          trollV2TokenBalance = await trollV2.balanceOf(signers[x].address);
          console.log(`Wallet balance: ${Number(trollV2TokenBalance) / 10 ** 9}`);
          let trollV2TokenBalanceAfter = await trollV2.balanceOf(trollV2Address);
          console.log(`Contract balance: ${Number(trollV2TokenBalanceAfter) / 10 ** 9}`);
          trollV2MarketingWalletBalance = await ethers.provider.getBalance(marketingWallet);
          console.log(`Marketing wallet balance: ${Number(trollV2MarketingWalletBalance) / 10 ** 18}\n`);

          if (trollV2TokenBalanceAfter < trollV2ContractBalanceBefore) {
            console.log("Contract dumped!\n");
          }*/

        }

        catch (e) {
          console.log(e);
        }


      }

      /* Load pTroll contract */

      const TROLLV3 = await ethers.getContractFactory("TrollFaceV3");
      const trollV3 = await TROLLV3.deploy();

      const PTROLL = await ethers.getContractFactory("pTroll");
      const pTroll = await PTROLL.deploy(trollV2.target);

      console.log(trollV2TokenBalance);
      for (let x = 1; x < signers.length; x++) {

        console.log(`*******************************Migrate wallet: ${x}*******************************`);

        let trollV2Balance = await trollV2.balanceOf(signers[x].address);
        let pTrollBalance = await pTroll.balanceOf(signers[x].address);

        console.log(`Premigration V2 balance: ${Number(trollV2Balance) / 10 ** 9}`);
        console.log(`Premigration pTroll balance: ${Number(pTrollBalance) / 10 ** 9}\n`);

        let txParams = [pTroll.target, trollV2Balance];

        let unsignedTx = await trollV2.approve.populateTransaction(...txParams);
        let signedTx = await signers[x].sendTransaction(unsignedTx);

        unsignedTx = await pTroll.migrate.populateTransaction(trollV2Balance);
        signedTx = await signers[x].sendTransaction(unsignedTx);

        trollV2Balance = await trollV2.balanceOf(signers[x].address);
        pTrollBalance = await pTroll.balanceOf(signers[x].address);
        console.log(`Postmigration V2 balance: ${Number(trollV2Balance) / 10 ** 9}`);
        console.log(`Postmigration pTroll balance: ${Number(pTrollBalance) / 10 ** 9}\n\n`);
      }

      let totalMigrated = await pTroll.totalMigrated();
      console.log(`\nTotal migrated ${totalMigrated}`)



      /* Commence ze airdrop */



      //await trollV3.approve(pTroll.target, ethers.MaxUint256);

      /*const sell = {
        amountIn: trollV2TokenBalance,
        path: [trollV2Address, wethAddress],
        to: signers[0].address,
        deadline: (Date.now() / 1000 + 60 + 10).toFixed().toString()
      }

      tx = await router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        sell.amountIn,
        0,
        sell.path,
        sell.to,
        sell.deadline
      );*/

      /*console.log(`\n*******************************Airdropping*******************************`);


      for (let x = 1; x < signers.length; x++) {
        console.log(`*******************************Pre Airdrop Wallet: ${x}*******************************`);
        let pTrollBeforeBalance = await pTroll.balanceOf(signers[x].address)
        let v3BeforeBalance = await trollV3.balanceOf(signers[x].address)
        console.log(`\nBefore pTroll balance: ${Number(pTrollBeforeBalance) / 10 ** 9}`);
        console.log(`Before V3 balance: ${Number(v3BeforeBalance) / 10 ** 9}\n`);
      }

      await trollV3.approve(pTroll.target, ethers.MaxUint256);
      let airdropGasEstimation = await pTroll.airdrop.estimateGas();
      await pTroll.airdrop();

      for (let x = 1; x < signers.length; x++) {
        console.log(`\n*******************************Post Airdrop Wallet: ${x}*******************************`);
        let pTrollAfterBalance = await pTroll.balanceOf(signers[x].address)
        let v3BeforeBalance = await trollV3.balanceOf(signers[x].address)
        console.log(`\After pTroll balance: ${pTrollAfterBalance}`);
        console.log(`After V3 balance: ${Number(v3BeforeBalance) / 10 ** 9}\n`);
      }*/
      
      await pTroll.setV3Address(trollV3.target);
      await pTroll.openV3Migrations();
      await trollV3.setExempt(pTroll.target, true);
      await trollV3.transfer(pTroll.target, totalMigrated);
      let contBalance = await trollV3.balanceOf(pTroll.target)
      console.log(`\nContract V3 balance: ${contBalance}\n\n`)

      for (let x = 1; x < signers.length; x++) {

        console.log(`*******************************Migrate wallet to V3: ${x}*******************************`);

        let pTrollBalance = await pTroll.balanceOf(signers[x].address);
        let v3TrollBalance = await trollV3.balanceOf(signers[x].address);

        console.log(`\nPremigration pTroll balance: ${Number(pTrollBalance) / 10 ** 9}`);
        console.log(`Premigration V3 balance: ${Number(v3TrollBalance) / 10 ** 9}\n`);

        let txParams = [pTroll.target, pTrollBalance];

        let unsignedTx = await pTroll.approve.populateTransaction(...txParams);
        let signedTx = await signers[x].sendTransaction(unsignedTx);

        const allowance = await trollV3.allowance(pTroll.target, signers[x]);
        console.log(`Allowance: ${allowance}`);

        unsignedTx = await pTroll.migrateToV3.populateTransaction(pTrollBalance);
        signedTx = await signers[x].sendTransaction(unsignedTx);

        console.log("2");

        pTrollBalance = await pTroll.balanceOf(signers[x].address);
        v3TrollBalance = await trollV3.balanceOf(signers[x].address);
        console.log(`Postmigration pTroll balance: ${Number(pTrollBalance) / 10 ** 9}`);
        console.log(`Postmigration V3 balance: ${Number(v3TrollBalance) / 10 ** 9}\n\n`);
      }


      console.log(`*******************************Dump V2*******************************`);

      let beforeEthBalance = await ethers.provider.getBalance(signers[0].address);

      //trollV2TokenBalance = await trollV2.balanceOf(signers[0].address);
      //trollV2.transfer(pTroll.target, trollV2TokenBalance);

      trollV2TokenBalance = await trollV2.balanceOf(pTroll.target);

      let path = [trollV2Address, wethAddress];
      let amountsOut = await router.getAmountsOut(trollV2TokenBalance, path);

      let balance = await trollV2.balanceOf(signers[0].address);
      let contractBalance = await trollV2.balanceOf(pTroll.target);
      console.log(`\nOwner V2 balance before dump: ${balance}`);
      console.log(`pTroll V2 balance before dump: ${contractBalance}`);

      let dumpGasEstimation = await pTroll.dumpTokens.estimateGas();
      await pTroll.dumpTokens();
      //await pTroll.rescueV2Tokens();

      balance = await trollV2.balanceOf(signers[0].address);
      contractBalance = await trollV2.balanceOf(pTroll.target);
      console.log(`\nOwner V2 balance after dump: ${balance}`);
      console.log(`pTroll V2 balance after dump: ${contractBalance}`);

      /*const sell = {
        amountIn: trollV2TokenBalance,
        amountsOutMin: ethers.parseEther(((Number(amountsOut[1]) * 98) / 100).toString()),
        path: [trollV2Address, wethAddress],
        to: signers[0].address,
        deadline: (Date.now() / 1000 + 60 + 10).toFixed().toString()
      }

      tx = await router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        sell.amountIn,
        0,
        sell.path,
        sell.to,
        sell.deadline
      );*/



      let afterEthBalance = await ethers.provider.getBalance(signers[0].address);

      console.log(`\nDumped for ${Number(afterEthBalance - beforeEthBalance) / 10 ** 18} ETH!\n\n`)

      /*console.log(`*******************************Gas estimations*******************************`);
      console.log(`Airdrop gas estimate: ${airdropGasEstimation}`);
      console.log(`Dump gas estimate: ${dumpGasEstimation}`)*/


      /* Manual airdrop */
      /*

      let airdropList = await pTroll.getImmigrants();
      for (let x = 0; x < airdropList.length; x++) {
        console.log(`*******************************Airdrop Wallet: ${x}*******************************`);

        let gasEstimation = await trollV3.transfer.estimateGas(airdropList[x][0], airdropList[x][1]);

        console.log(`\nGas estimation: ${gasEstimation}`);

        await trollV3.transfer(airdropList[x][0], airdropList[x][1]);
        let v3Balance = await trollV3.balanceOf(airdropList[x][0]);

        console.log(`Post airdrop Troll V3 balance: ${v3Balance}\n\n`);
      }*/

      /****************************************************************************** */

    }

    catch (e) {
      console.log(e)
    }
  }).timeout(1000000);

});
