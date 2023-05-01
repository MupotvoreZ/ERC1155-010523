// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
//import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";


contract TulNFT is Context, Ownable, Pausable, ERC1155Burnable { //ERC1155Supply {
    // IPFS hash for metadata
    string private _metadataIPFSHash;
    
    // Sale price in wei
    uint256 public constant SALE_PRICE = 0.1 ether;

    // Whitelist of buyers
    mapping(address => bool) private _buyerWhitelist;

    constructor(string memory metadataIPFSHash) ERC1155(metadataIPFSHash) {
        _metadataIPFSHash = metadataIPFSHash;
    }

    function uri(uint256) public view override returns (string memory) {
        return string(abi.encodePacked("ipfs://", _metadataIPFSHash));
    }

    function buyNft(uint256 tokenId) public payable whenNotPaused {
        require(_buyerWhitelist[_msgSender()], "TulNFT: caller is not whitelisted");
        require(msg.value == SALE_PRICE, "TulNFT: incorrect payment amount");

        _mint(_msgSender(), tokenId, 1, "");
    }

    function mint(address account, uint256 tokenId, uint256 amount) public onlyOwner {
        _mint(account, tokenId, amount, "");
    }

    function addToWhitelist(address buyer) public onlyOwner {
        _buyerWhitelist[buyer] = true;
    }

    function removeFromWhitelist(address buyer) public onlyOwner {
        _buyerWhitelist[buyer] = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }
}