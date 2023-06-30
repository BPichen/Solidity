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

            const TROLLV3 = await ethers.getContractFactory("TrollFaceV3");
            const trollV3 = await TROLLV3.deploy();

            const trollV3PairAddress = await trollV3.uniswapV2Pair();
            const trollV3Address = trollV3.target;
            const trollV3Supply = await trollV3.totalSupply();
            const trollV2Decimals = await trollV3.decimals();

            const wethAddress = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
            const weth = await ethers.getContractAt("WETH", wethAddress);

            const trollV3Pair = await ethers.getContractAt("UniswapV2ERC20", trollV3PairAddress);

            /*******************************************************************************/

            var deadline = Date.now() / 1000 + 60 + 10;
            const ethToLP = ethers.parseEther("150");

            await trollV3.approve(routerAddress, ethers.MaxUint256);

            var trollV3TokenBalance = await trollV3.balanceOf(signers[0].address);
            var lpBalance = await trollV3Pair.balanceOf(signers[0].address);

            const trollV3TokensForLP = BigInt(trollV3Supply * BigInt(20) / BigInt(100));

            await router.addLiquidityETH(
                trollV3Address,
                trollV3TokensForLP,
                0,
                0,
                signers[0].address,
                deadline.toFixed().toString(),
                {
                    value: ethToLP
                }
            );

            trollV3TokenBalance = await trollV3.balanceOf(signers[0].address);
            lpBalance = await trollV3Pair.balanceOf(signers[0].address);

            await trollV3Pair.transfer(dead, lpBalance);

            var tx = await trollV3.transfer(dead, trollV3TokenBalance);

            trollV3TokenBalance = await trollV3.balanceOf(signers[0].address);

            await trollV3.openTrading();

            /*for (let x = 1; x < 3; x++) {

                try {

                    //Buy tokens

                    console.log(`\n*******************************Buy/Sell V3 Wallet: ${x}*******************************`);

                    let v3BeforeBalance = await trollV3.balanceOf(signers[x].address)
                    var precision = 100;
                    var randomNum = Math.floor(Math.random() * (10 * precision - 1 * precision) + 1 * precision) / (1 * precision);
                    console.log(randomNum);
                    const buy = {
                        min: 0,
                        eth: ethers.parseEther(randomNum.toString()),
                        path: [wethAddress, trollV3Address],
                        to: signers[x].address,
                        deadline: (Date.now() / 1000 + 60 + 10).toFixed().toString()
                    }

                    let unsignedTx = await router.swapExactETHForTokens.populateTransaction(buy.min, buy.path, buy.to, buy.deadline);
                    let signedTx = await signers[x].sendTransaction(unsignedTx);

                    let trollV3MarketingWalletBalanceBefore = await trollV3.balanceOf(marketingWallet);

                    //await router.swapExactETHForTokens(
                        //buy.min,
                        //buy.path,
                        //buy.to,
                        //buy.deadline,
                        //{
                            //value: buy.eth
                        //}
                    //)
                    console.log("Buy:")
                    trollV3TokenBalance = await trollV3.balanceOf(signers[x].address);
                    console.log(`- Wallet balance before buy: ${Number(v3BeforeBalance) / 10 ** 9}`);
                    console.log(`- Wallet balance after buy: ${Number(trollV3TokenBalance) / 10 ** 9}\n`);
                    let trollV3MarketingWalletBalanceAfter = await trollV3.balanceOf(marketingWallet);
                    console.log(`- Marketing wallet balance before: ${Number(trollV3MarketingWalletBalanceBefore) / 10 ** 9}`);
                    console.log(`- Marketing wallet balance after: ${Number(trollV3MarketingWalletBalanceAfter) / 10 ** 9}\n`);
                    //Sell tokens

                    trollV3TokenBalance = await trollV3.balanceOf(signers[x].address);

                    const sell = {
                        amountIn: trollV3TokenBalance,
                        path: [trollV3Address, wethAddress],
                        to: signers[x].address,
                        deadline: (Date.now() / 1000 + 60 + 10).toFixed().toString()
                    }

                    trollV3MarketingWalletBalanceBefore = await trollV3.balanceOf(marketingWallet);

                    let txParams = [routerAddress, trollV3TokenBalance];
                    v3BeforeBalance = await trollV3.balanceOf(signers[x].address)

                    unsignedTx = await trollV3.approve.populateTransaction(...txParams);
                    signedTx = await signers[x].sendTransaction(unsignedTx);

                    unsignedTx = await router.swapExactTokensForETHSupportingFeeOnTransferTokens.populateTransaction(sell.amountIn, 0, sell.path, sell.to, sell.deadline)
                    signedTx = await signers[x].sendTransaction(unsignedTx);
                    //await router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                        //sell.amountIn,
                        //0,
                        //sell.path,
                        //sell.to,
                        //sell.deadline
                    //);

                    console.log("Sell:")
                    trollV3TokenBalance = await trollV3.balanceOf(signers[x].address);
                    console.log(`- Wallet balance before sell: ${Number(v3BeforeBalance) / 10 ** 9}`);
                    let trollV3WalletBalanceAfter = await trollV3.balanceOf(signers[x].address);
                    console.log(`- Wallet balance after sell: ${Number(trollV3WalletBalanceAfter) / 10 ** 9}\n`);
                    trollV3MarketingWalletBalanceAfter = await trollV3.balanceOf(marketingWallet);
                    console.log(`- Marketing wallet balance before: ${Number(trollV3MarketingWalletBalanceBefore) / 10 ** 9}`);
                    console.log(`- Marketing wallet balance after[0]: ${Number(trollV3MarketingWalletBalanceAfter) / 10 ** 9}\n`);
                }

                catch (e) {
                    console.log(e);
                }

            }*/

            const gasEstimation = await trollV3.openTrading.estimateGas()

            console.log(`\n\nState change gas esimate: ${gasEstimation}`);
        }

        catch (e) {
            console.log(e)
        }
    }).timeout(1000000);

});
