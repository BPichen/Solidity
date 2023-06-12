//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Splitter {

address payable account1 = payable(0xe616C252E8d42f6a859b6D4439361690C9a61557);
address payable account2 = payable(0xF6B82C068960B3C52851A5c51236710D87304eD7);
address payable account3 = payable(0xf092d913B7E1EFEA820D679b6e8fD15775765d99);


    receive() external payable {
            uint256 payment = address(this).balance / 3;
                payable(account1).transfer(payment);
                payable(account2).transfer(payment);
                payable(account3).transfer(payment);

        }

    function clearStuckBeans() external{
                uint256 payment = address(this).balance / 3;
                payable(account1).transfer(payment);
                payable(account2).transfer(payment);
                payable(account3).transfer(payment);
    }

}