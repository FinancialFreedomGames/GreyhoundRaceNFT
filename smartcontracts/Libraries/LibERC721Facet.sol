// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}

library LibERC721Facet {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
    function supportsInterface(bytes4 interfaceId) internal view returns (bool) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.supportedInterfaces[interfaceId];
    }
    function balanceOf(address owner) internal view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._balances[owner];
    }
    function ownerOf(uint256 tokenId) internal view returns (address) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        address owner = ds.nftsData._owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function name() internal view returns (string memory) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._name;
    }
    function symbol() internal view returns (string memory) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._symbol;
    }
    function tokenURI(uint256 tokenId) internal view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        string memory id;
        assembly{
            id := tokenId
        }
        return bytes(baseURI).length > 0 ? string.concat(baseURI,id) : "";
    }
    function _baseURI() internal pure returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) internal view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) internal {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) internal view returns (bool) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._operatorApprovals[owner][operator];
    }
    function transferFrom(address from,address to,uint256 tokenId) internal {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) internal {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, "");
    }
    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _safeMint(address to,string memory _object,bytes memory _data) internal {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        uint256 tokenId=ds.nftsData._counter;
        require(tokenId<type(uint256).max,"ERC721: max cap overflow");
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        ds.nftsData._balances[to] += 1;
        ds.nftsData._owners[tokenId] = to;
        ds.nftsData._counterByObject[_object]++;
        ds.nftsData._allTokensData[tokenId]=GreyhoundRace.dataNFT(_object,_data);
        ds.nftsData._counter=tokenId+1;
        require(
            _checkOnERC721Received(address(0), to, tokenId, ""),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);// Clear approvals
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._balances[owner] -= 1;
        delete  ds.nftsData._owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from,address to,uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);// Clear approvals from the previous owner
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._balances[from] -= 1;
        ds.nftsData._balances[to] += 1;
        ds.nftsData._owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(address owner,address operator,bool approved) internal {
        require(owner != operator, "ERC721: approve to caller");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _checkOnERC721Received(address from,address to,uint256 tokenId,bytes memory _data) internal returns (bool) {
        if (GreyhoundRace.isContract(to)) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) internal view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._ownedTokens[owner][index];
    }
    function totalSupply() internal view returns (uint256) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._allTokens.length;
    }
    function tokenByIndex(uint256 index) internal view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._allTokens[index];
    }
    function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal {
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) internal {
        uint256 length = balanceOf(to);
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._ownedTokens[to][length] = tokenId;
        ds.nftsData._ownedTokensIndex[tokenId] = length;
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) internal {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._allTokensIndex[tokenId] = ds.nftsData._allTokens.length;
        ds.nftsData._allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) internal {
        uint256 lastTokenIndex = balanceOf(from) - 1;
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        uint256 tokenIndex = ds.nftsData._ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = ds.nftsData._ownedTokens[from][lastTokenIndex];
            ds.nftsData._ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            ds.nftsData._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }
        delete ds.nftsData._ownedTokensIndex[tokenId];
        delete ds.nftsData._ownedTokens[from][lastTokenIndex];
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) internal {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        uint256 lastTokenIndex = ds.nftsData._allTokens.length - 1;
        uint256 tokenIndex = ds.nftsData._allTokensIndex[tokenId];
        uint256 lastTokenId = ds.nftsData._allTokens[lastTokenIndex];
        ds.nftsData._allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        ds.nftsData._allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        delete ds.nftsData._allTokensIndex[tokenId];
        ds.nftsData._allTokens.pop();
    }
    function getTokenData(uint256 tokenId) internal view returns (GreyhoundRace.dataNFT memory) {
        require(_exists(tokenId), "ERC721Metadata: data query for nonexistent token");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.nftsData._allTokensData[tokenId];
    }
    function setTokenData(uint256 tokenId,string memory _object,bytes memory _data) internal {
        require(_msgSender() == ownerOf(tokenId), "ERC721: token data caller is not owner");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.nftsData._allTokensData[tokenId]=GreyhoundRace.dataNFT(_object,_data);
    }
}