// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    uint256 private test = 1;


    function getTest() view external returns (uint256) {
        return test;
    }
}
