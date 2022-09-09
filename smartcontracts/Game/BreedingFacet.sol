// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
import { LibERC721Facet } from "../Libraries/LibERC721Facet.sol";
import { LibGreyhound } from "../Libraries/LibGreyhound.sol";
contract BreedingFacet {
    uint private constant WEEK = 7 * 24 * 60 * 60;

    function breedGreyhound(string memory _name,uint _dad,uint _mom) external {
        _mintGreyhound(_breedingGreyhound(_name, _dad, _mom)); //rng
    }
    function _mintGreyhound(bytes memory _greyhoundData) internal {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        LibERC721Facet._safeMint(msg.sender,"greyhound",_greyhoundData);
        ds.nftsData._counterByObject["greyhound_by_breed"]++;
    }
    function _dataBy(uint _tokenID) private view returns (bytes memory _data){
        GreyhoundRace.dataNFT memory g=LibERC721Facet.getTokenData(_tokenID);
        require(LibGreyhound.isValid(g._object),"Invalid Object");
        _data=g._data;
    }
    function _breedingGreyhound(string memory _name,uint _dad,uint _mom) internal view returns (bytes memory) {
        require(msg.sender == LibERC721Facet.ownerOf(_dad) && msg.sender == LibERC721Facet.ownerOf(_mom), "Not Owner of parents");
        LibGreyhound.Greyhound memory dad=LibGreyhound.decode(_dataBy(_dad));
        LibGreyhound.Greyhound memory mom=LibGreyhound.decode(_dataBy(_mom));
        require(dad.isMale && !mom.isMale, "Can't breed with this parents");
        return abi.encodePacked(
            bytes20(bytes(_name)),//name
            bytes4(uint32(block.timestamp + WEEK)),//bornDate
            bytes32(_dad),//dad
            bytes32(_mom),//mom
            bytes2(0),//current Races
            _maxRacesAndRarity(),
            _attributes(dad, mom),
            bytes10(0),//exp. Attributes
            _gender(),
            bytes1(0),//num Pregnant
            bytes14(0),//end Pregnant Date 4 bytes, end Training Date 4 bytes, injured Date 4 bytes, hours Trained 1 byte, consecutive Training 1 byte
            bytes6(0),//en Race 4 bytes,consecutive Races 2 bytes
            _color(dad.color, mom.color),//color
            bytes4(0)//resetDate
        );
    }
    function _color(bytes3 color_dad,bytes3 color_mom) internal view returns (bytes3 color) {
        assembly{
            color := add(div(mul(color_dad,20),100),div(mul(color_mom,80),100))
        }
    }
    function _gender() internal view returns (bytes1) {
        if(GreyhoundRace.randomNum(100)<20){//20%
            return 0x00;//female
        }else{
            return 0x01;//male
        }
    }
    function _attributes(LibGreyhound.Greyhound memory _dad,LibGreyhound.Greyhound memory _mom) internal view returns (bytes memory) {
        uint speed=GreyhoundRace.randomNum(100)<20?_dad.speed:_mom.speed;
        uint strength=GreyhoundRace.randomNum(100)<20?_dad.strength:_mom.strength;
        uint agility=GreyhoundRace.randomNum(100)<20?_dad.agility:_mom.agility;
        uint reaction_time=GreyhoundRace.randomNum(100)<20?_dad.reaction_time:_mom.reaction_time;
        uint endurance=GreyhoundRace.randomNum(100)<20?_dad.endurance:_mom.endurance;
        uint maxPoints=500;
        //Sets the sum of the attributes according to maxPoints if sum is greater than maxPoints
        assembly{
            let sum := add(add(add(add(speed,strength),agility),reaction_time),endurance)
            if gt(sum,maxPoints) {
                speed := div(mul(speed,maxPoints),sum)
                strength := div(mul(strength,maxPoints),sum)
                agility := div(mul(agility,maxPoints),sum)
                reaction_time := div(mul(reaction_time,maxPoints),sum)
                endurance := div(mul(endurance,maxPoints),sum)
            }
        }
        return abi.encodePacked(uint16(speed),uint16(strength),uint16(agility),uint16(reaction_time),uint16(endurance));
    }
    function _maxRacesAndRarity() internal view returns (bytes3) {
        uint num=GreyhoundRace.randomNum(10000);
        if(num<5000){//50%
            return 0x271000;//10K Races 2 Bytes, Commom 1 Byte
        }else if(num<7880){//5000+2880 = 50%+28.8%
            return 0x2EE001;//12K Races 2 Bytes, Rare 1 Byte
        }else if(num<9780){//5000+2880+1900 = 50%+28.8%+19%
            return 0x36B002;//14K Races 2 Bytes, Epic 1 Byte
        }else if(num<9980){//5000+2880+1900+200 = 50%+28.8%+19%+2%
            return 0x3E8003;//16K Races 2 Bytes, Legendary 1 Byte
        }else{
            return 0x4E2004;//20K Races 2 Bytes, Mythic 1 Byte
        }
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](1);
        selector[0]=this.breedGreyhound.selector;
    }
}