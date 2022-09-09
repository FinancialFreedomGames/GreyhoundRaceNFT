// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
import { LibERC721Facet } from "../Libraries/LibERC721Facet.sol";
import { LibGreyhound } from "../Libraries/LibGreyhound.sol";
import { LibStatusGreyhound } from "../Libraries/LibStatusGreyhound.sol";

contract GreyhoundFacet {

    function _dataBy(uint _tokenID) private view returns (bytes memory _data){
        GreyhoundRace.dataNFT memory g=LibERC721Facet.getTokenData(_tokenID);
        require(LibGreyhound.isValid(g._object),"Invalid Object");
        _data=g._data;
    }
    function decodeGreyhound(uint _tokenID) external view returns (LibGreyhound.Greyhound memory greyhound) {
        greyhound=LibGreyhound.decode(_dataBy(_tokenID));
    }
    function setNameGreyhound(uint _tokenID, string memory _name) external {
        require(bytes(_name).length<21,"Name more than 20 characters");
        LibGreyhound.Greyhound memory gr=LibGreyhound.decode(_dataBy(_tokenID));
        gr.name=string(abi.encodePacked(bytes20(bytes(_name))));
        LibERC721Facet.setTokenData(_tokenID,"greyhound",LibGreyhound.encode(gr));
    }
    function isBorn(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.isBorn(_dataBy(_tokenID));
    }
    function isChild(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.isChild(_dataBy(_tokenID));
    }
    function inTraining(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.inTraining(_dataBy(_tokenID));
    }
    function isInjured(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.isInjured(_dataBy(_tokenID));
    }
    function inRace(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.inRace(_dataBy(_tokenID));
    }
    function isPregnant(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.isPregnant(_dataBy(_tokenID));
    }
    function canRace(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.canRace(_dataBy(_tokenID));
    }
    function canBreed(uint _tokenID) external view returns(bool){
        return LibStatusGreyhound.canBreed(_dataBy(_tokenID));
    }
    function canTrain(uint _tokenID, uint _hours) external view returns(bool){
        return LibStatusGreyhound.canTrain(_dataBy(_tokenID),_hours,8);
    }

    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](11);
        selector[0]=this.decodeGreyhound.selector;
        selector[1]=this.setNameGreyhound.selector;
        selector[2]=this.isBorn.selector;
        selector[3]=this.isChild.selector;
        selector[4]=this.inTraining.selector;
        selector[5]=this.isInjured.selector;
        selector[6]=this.inRace.selector;
        selector[7]=this.isPregnant.selector;
        selector[8]=this.canRace.selector;
        selector[9]=this.canBreed.selector;
        selector[10]=this.canTrain.selector;
    }

}