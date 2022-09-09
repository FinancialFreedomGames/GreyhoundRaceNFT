// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
import { LibERC721Facet } from "../Libraries/LibERC721Facet.sol";
import { LibERC20 } from "../Libraries/LibERC20.sol";
import { LibGreyhound } from "../Libraries/LibGreyhound.sol";
import { LibStatusGreyhound } from "../Libraries/LibStatusGreyhound.sol";

contract TrainerFacet {
    uint private constant HOUR = 60 * 60;
    uint private constant DAY = 24 * 60 * 60;

    function train(uint _tokenID,uint _hours,uint _stat) external {
        require(_hours==1 || _hours==2 || _hours==4 || _hours==8,"Invalid Hours");
        require(LibERC721Facet.ownerOf(_tokenID)==msg.sender,"Not Owner");
        require(_stat<5,"Invalid Stat");
        GreyhoundRace.dataNFT memory g=LibERC721Facet.getTokenData(_tokenID);
        require(LibGreyhound.isValid(g._object),"Invalid Token ID");
        require(canTrain(g._data,_hours),"Can't Train");
        (,,,,,uint sum)=LibGreyhound._getAttributes(g._data);
        require(sum<500,"Greyhound Maxed");
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        address _token=ds.coin;
        uint decimals=10**LibERC20.safeDecimals(_token);
        address _devWallet=0xd6302419248E2B1cE0c7532d984B29Fe1EC39275; //Polygon mainnet
        LibERC20.safeTransferFrom(_token,msg.sender,_devWallet,_hours*decimals/2);
        LibERC721Facet.setTokenData(
            _tokenID,
            g._object,
            LibGreyhound.encode(
                updateTrainingData(
                    levelUpStat(g._data, _hours, _stat),
                    _hours
                )
            )
        );
    }
    function updateTrainingData(LibGreyhound.Greyhound memory gr, uint _hours) internal view returns (LibGreyhound.Greyhound memory){
        gr.endTrainingDate=uint32(block.timestamp + _hours*HOUR);
        if(gr.resetDate<block.timestamp){
            gr.resetDate=uint32(((block.timestamp/DAY) + 1) * DAY);
            gr.hoursTrained=uint8(_hours);
            gr.consecutiveTraining=0;
        }else{
            gr.hoursTrained+=uint8(_hours);
            gr.consecutiveTraining++;
        }
        if(injuredInTraining(gr.consecutiveTraining)){
            gr.endInjuredDate=uint32(block.timestamp + DAY);
        }
        return gr;
    }
    function levelUpStat(bytes memory _data, uint _hours,uint _stat) internal view returns (LibGreyhound.Greyhound memory gr){
        uint16 exp=experienceByHours(_data,_hours);
        gr=LibGreyhound.decode(_data);
        if(_stat==0){//speed
            gr.exp_speed+=exp;
            if(gr.exp_speed>=1000){
                gr.exp_speed-=1000;
                gr.speed++;
            }
        }else if(_stat==1){//strength
            gr.exp_strength+=exp;
            if(gr.exp_strength>=1000){
                gr.exp_strength-=1000;
                gr.strength++;
            }
        }else if(_stat==2){//agility
            gr.exp_agility+=exp;
            if(gr.exp_agility>=1000){
                gr.exp_agility-=1000;
                gr.agility++;
            }
        }else if(_stat==3){//reaction_time
            gr.exp_reaction_time+=exp;
            if(gr.exp_reaction_time>=1000){
                gr.exp_reaction_time-=1000;
                gr.reaction_time++;
            }
        }else if(_stat==4){//endurance
            gr.exp_endurance+=exp;
            if(gr.exp_endurance>=1000){
                gr.exp_endurance-=1000;
                gr.endurance++;
            }
        }
    }
    function injuredInTraining(uint _consecutiveTraining) internal view returns (bool){
        if(_consecutiveTraining==0){
            return false;
        }
        uint probGetInjured=85-(100/(1+_consecutiveTraining));
        return GreyhoundRace.randomNum(100)<probGetInjured;
    }
    function experienceByHours(bytes memory _data, uint _hours) internal view returns (uint16 exp){
        if(_hours==1){
            exp=20;
        }else if(_hours==2){
            exp=32;
        }else if(_hours==4){
            exp=48;
        }else if(_hours==8){
            exp=80;
        }
        if(LibStatusGreyhound.isChild(_data)){
            exp=exp*3;
        }
    }
    function canTrain(bytes memory _data, uint _hours) internal view returns (bool){
        uint maxHours=LibStatusGreyhound.isChild(_data)?4:8;
        return LibStatusGreyhound.canTrain(_data, _hours, maxHours);
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](1);
        selector[0]=this.train.selector;
    }
}