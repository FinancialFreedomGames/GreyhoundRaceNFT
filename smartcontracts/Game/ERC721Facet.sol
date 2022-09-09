// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
import { LibERC721Facet } from "../Libraries/LibERC721Facet.sol";
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
contract ERC721Facet {
    function balanceOf(address owner) external view returns (uint256) {
        return LibERC721Facet.balanceOf(owner);
    }
    function ownerOf(uint256 tokenId) external view returns (address) {
        return LibERC721Facet.ownerOf(tokenId);
    }
    function name() external view returns (string memory) {
        return LibERC721Facet.name();
    }
    function symbol() external view returns (string memory) {
        return LibERC721Facet.symbol();
    }
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return LibERC721Facet.tokenURI(tokenId);
    }
    function approve(address to, uint256 tokenId) external {
        LibERC721Facet.approve(to,tokenId);
    }
    function getApproved(uint256 tokenId) external view returns (address) {
        return LibERC721Facet.getApproved(tokenId);
    }
    function setApprovalForAll(address operator, bool approved) external {
        LibERC721Facet.setApprovalForAll(operator,approved);
    }
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return LibERC721Facet.isApprovedForAll(owner,operator);
    }
    function transferFrom(address from,address to,uint256 tokenId) external {
        LibERC721Facet.transferFrom(from,to,tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) external {
        LibERC721Facet.safeTransferFrom(from,to,tokenId);
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return LibERC721Facet.tokenOfOwnerByIndex(owner,index);
    }
    function totalSupply() external view returns (uint256) {
        return LibERC721Facet.totalSupply();
    }
    function tokenByIndex(uint256 index) external view returns (uint256) {
        return LibERC721Facet.tokenByIndex(index);
    }
    function getTokenData(uint256 tokenId) external view returns (GreyhoundRace.dataNFT memory) {
        return LibERC721Facet.getTokenData(tokenId);
    }
    function totalSupplyOf(string memory _object) external view returns (uint256) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._counterByObject[_object];
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](16);
        selector[0]=this.totalSupplyOf.selector;
        selector[1]=this.balanceOf.selector;
        selector[2]=this.ownerOf.selector;
        selector[3]=this.name.selector;
        selector[4]=this.symbol.selector;
        selector[5]=this.tokenURI.selector;
        selector[6]=this.approve.selector;
        selector[7]=this.getApproved.selector;
        selector[8]=this.setApprovalForAll.selector;
        selector[9]=this.isApprovedForAll.selector;
        selector[10]=this.transferFrom.selector;
        selector[11]=this.safeTransferFrom.selector;
        selector[12]=this.tokenOfOwnerByIndex.selector;
        selector[13]=this.totalSupply.selector;
        selector[14]=this.tokenByIndex.selector;
        selector[15]=this.getTokenData.selector;
    }
    function initialize() external {
        /*
        GreyhoundRace.whenPermited();
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._name="GreyHoundRace NFTs";
        ds.nftsData._symbol="GHR NFTs";
        ds.supportedInterfaces[type(IERC721).interfaceId]=true;
        ds.supportedInterfaces[type(IERC721Metadata).interfaceId]=true;
        ds.supportedInterfaces[type(IERC165).interfaceId]=true;
        ds.supportedInterfaces[type(IERC721Enumerable).interfaceId]=true;*/
    }
}