//SPDX-License-Identifier: MIT
                                                                       
pragma solidity >=0.8.12 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract baseNFT is ERC721URIStorage{
    uint256 public tokenCounter;
    address private deployer;

    constructor() 
    public
    ERC721("SampleContract", "SC") {
        tokenCounter = 0;
        deployer = address(msg.sender);
    }

    function createCollectible(string memory tokenURI) external returns (uint256) {
        require(msg.sender == deployer);
        uint256 newTokenId = tokenCounter;
        _mint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenURI);
        tokenCounter = tokenCounter + 1;

        return newTokenId;
    }
    
}