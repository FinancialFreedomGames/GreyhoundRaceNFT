// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
import { LibERC721Facet } from "../Libraries/LibERC721Facet.sol";
import { LibERC20 } from "../Libraries/LibERC20.sol";
contract MinterFacet {
    uint immutable private endPrivateSaleDate;
    constructor(){
        endPrivateSaleDate=block.timestamp+(60*60*24*14);//60*60*24*14 = 14 days
    }
    function buyGreyhound(uint _amount) external {
        //        100GHRCoin    120$ private     160$ public    60$ public
        require(_amount==100 || _amount==120 || _amount==160 || _amount==60,"Invalid amount");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        if(_amount==120){
            require(block.timestamp<endPrivateSaleDate,"Private sale complete");
            require(ds.whitelist[msg.sender],"Not in whitelist");
        }else{
            require(block.timestamp>endPrivateSaleDate,"Private sale active");
        }
        address _token=ds.coin;
        uint decimals=10**LibERC20.safeDecimals(_token);
        address _devWallet=0xd6302419248E2B1cE0c7532d984B29Fe1EC39275; //Polygon mainnet
        if(_amount==100){
            _token=0xe4DF6d512Bb4C18089FdC1Bb07CDAB562F9cE0CA; //GHRCoin Polygon mainnet
            decimals=1;
        }
        LibERC20.safeTransferFrom(_token,msg.sender,_devWallet,_amount*decimals);
        if(_amount==60 || _amount==100){
            _mintGreyhound(_getGreyhound(false));//rng
        }else{
            _mintGreyhound(_getGreyhound(true)); //force female
            _mintGreyhound(_getGreyhound(false)); //rng
            _mintGreyhound(_getGreyhound(false)); //rng
        }
    }
    function _mintGreyhound(bytes memory _greyhoundData) internal {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        uint count=ds.nftsData._counterByObject["greyhound_by_mint"];
        require(count<15000,"Hard Cap Reached");
        LibERC721Facet._safeMint(msg.sender,"greyhound",_greyhoundData);
        ds.nftsData._counterByObject["greyhound_by_mint"]=count+1;
    }
    function _getGreyhound(bool forceFemale) internal view returns (bytes memory) {
        return abi.encodePacked(
            bytes20("No Name"),//name
            bytes4(0),//bornDate
            bytes32(0),//dad
            bytes32(0),//mom
            bytes2(0),//current Races
            _maxRacesAndRarity(),
            _attributes(50),
            bytes10(0),//exp. Attributes
            forceFemale?bytes1(0):_gender(),
            bytes1(0),//num Pregnant
            bytes14(0),//end Pregnant Date 4 bytes, end Training Date 4 bytes, injured Date 4 bytes, hours Trained 1 byte, consecutive Training 1 byte
            bytes6(0),//en Race 4 bytes,consecutive Races 2 bytes
            _color(),//color
            bytes4(0)//resetDate
        );
    }
    function _color() internal view returns (bytes3) {
        bytes3[] memory colors=new bytes3[](85);
        colors[0]=0xa52a2a;
        colors[1]=0xffe4c4;
        colors[2]=0xffe4b5;
        colors[3]=0xffdead;
        colors[4]=0xf4a460;
        colors[5]=0xbc8f8f;
        colors[6]=0xcd853f;
        colors[7]=0xd2691e;
        colors[8]=0xa0522d;
        colors[9]=0x8b4513;
        colors[10]=0xfdf5e6;
        colors[11]=0xfff8e7;
        colors[12]=0xffefd5;
        colors[13]=0xfaebd7;
        colors[14]=0xffddca;
        colors[15]=0xffe4cd;
        colors[16]=0xffebcd;
        colors[17]=0xf0ead6;
        colors[18]=0xf7e7ce;
        colors[19]=0xffe4c4;
        colors[20]=0xefdecd;
        colors[21]=0xefdfbb;
        colors[22]=0xf5deb3;
        colors[23]=0xfadfad;
        colors[24]=0xedc9af;
        colors[25]=0xfad6a5;
        colors[26]=0xddadaf;
        colors[27]=0xdeaa88;
        colors[28]=0xe9967a;
        colors[29]=0xc09999;
        colors[30]=0xcd9575;
        colors[31]=0xda8a67;
        colors[32]=0xd99058;
        colors[33]=0xc19a6b;
        colors[34]=0xcb6d51;
        colors[35]=0xad6f69;
        colors[36]=0xba8759;
        colors[37]=0xc95a49;
        colors[38]=0xcd5b45;
        colors[39]=0x9f8170;
        colors[40]=0xa57164;
        colors[41]=0xb94e48;
        colors[42]=0xcd7f32;
        colors[43]=0x986960;
        colors[44]=0xa0785a;
        colors[45]=0x987456;
        colors[46]=0xcc7722;
        colors[47]=0x987654;
        colors[48]=0xb87333;
        colors[49]=0xc0362c;
        colors[50]=0xbb6528;
        colors[51]=0x80755a;
        colors[52]=0x836953;
        colors[53]=0x965a3e;
        colors[54]=0xb5651d;
        colors[55]=0x954535;
        colors[56]=0x826644;
        colors[57]=0xaa381e;
        colors[58]=0xb7410e;
        colors[59]=0xc04000;
        colors[60]=0x922724;
        colors[61]=0x704241;
        colors[62]=0x79443b;
        colors[63]=0xb06500;
        colors[64]=0x8a3324;
        colors[65]=0x6f4e37;
        colors[66]=0x703642;
        colors[67]=0xa75502;
        colors[68]=0x882d17;
        colors[69]=0x80461b;
        colors[70]=0x964b00;
        colors[71]=0x664c28;
        colors[72]=0x6b4423;
        colors[73]=0x6c541e;
        colors[74]=0x654321;
        colors[75]=0x704214;
        colors[76]=0x644117;
        colors[77]=0x7b3f00;
        colors[78]=0x592720;
        colors[79]=0x4b3621;
        colors[80]=0x3c341f;
        colors[81]=0x3d2b1f;
        colors[82]=0x3c1414;
        colors[83]=0x321414;
        colors[84]=0x3d0c02;
        return colors[GreyhoundRace.randomNum(85)];
    }
    function _gender() internal view returns (bytes1) {
        if(GreyhoundRace.randomNum(100)<20){//20%
            return 0x00;//female
        }else{
            return 0x01;//male
        }
    }
    function _attributes(uint maxPoints) internal view returns (bytes memory) {
        uint speed=GreyhoundRace.randomNum(maxPoints);
        uint strength=GreyhoundRace.randomNum(maxPoints);
        uint agility=GreyhoundRace.randomNum(maxPoints);
        uint reaction_time=GreyhoundRace.randomNum(maxPoints);
        uint endurance=GreyhoundRace.randomNum(maxPoints);
        maxPoints=GreyhoundRace.randomNum(maxPoints);
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
            return 0x2EE001;//12K Races 2 Bytes, Uncommon 1 Byte
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
        selector[0]=this.buyGreyhound.selector;
    }
}