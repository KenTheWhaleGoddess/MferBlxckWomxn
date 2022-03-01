//"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.7;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

enum SaleState {
    NOSALE, MAINSALE
}

contract SimpleCollectible is ERC721A, Ownable, ReentrancyGuard {
    uint256 private tokenCounter;

    uint256 public salePrice = 10000000000000000;

    uint256 private maxSupply = 50; 

    uint256 private maxPerTx = 25;

    string private baseTokenURI;
    SaleState public saleState; // 0 - No sale. 1 - Main Sale.

    constructor () ERC721A ("Mfer Black Womxn","MFXR", maxPerTx, maxSupply)  {
        setBaseURI("ipfs://QmXYmXrXwhGEMrWQjtDBBLiewGS7VTgWANDL1D45XUD21S/");
    }

    function mintCollectibles(uint256 _count) public payable nonReentrant {
        require(saleState == SaleState.MAINSALE, "Sale is not yet open");
 
        require((_count + tokenCounter) <= maxSupply, "Ran out of NFTs for sale! Sry!");
        require(msg.value >= (salePrice * _count), "Ether value sent is not correct");

        _safeMint(msg.sender, _count);
         tokenCounter += _count;
    }

    function mintForOwner(uint256 _count, address _user) public onlyOwner { 
        require((_count + tokenCounter) <= maxSupply, "Ran out of NFTs for sale! Sry!");

        _safeMint(_user, _count);
         tokenCounter += _count;
    }

    function getMaxSupply() public view returns (uint256) {
        return maxSupply - 1;
    }

    function getMaxPerTx() public view returns (uint256) {
        return maxPerTx;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(getBaseURI(), Strings.toString(tokenId), ".json"));
    }
    
    function setSaleState(SaleState _saleState) public onlyOwner {
        saleState = _saleState;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseTokenURI = uri;
    }

    function getBaseURI() public view returns (string memory){
        return baseTokenURI;
    }

    function withdrawReparations() public payable onlyOwner nonReentrant {
        require(payable(msg.sender).send(address(this).balance));
    }
}
