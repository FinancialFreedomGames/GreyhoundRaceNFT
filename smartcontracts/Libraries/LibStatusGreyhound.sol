// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import { LibGreyhound } from "../Libraries/LibGreyhound.sol";
library LibStatusGreyhound {
    function isBorn(bytes memory _g) internal view returns(bool){
        return block.timestamp > LibGreyhound._getBornDate(_g);
    }
    function isChild(bytes memory _g) internal view returns (bool){
        require(isBorn(_g),"Not Born");
        return block.timestamp < (LibGreyhound._getBornDate(_g) + (60*60*24*7));
    }
    function inTraining(bytes memory _g) internal view returns (bool){
        (uint32 endTrainingDate,,,)=LibGreyhound._getTrainedVar(_g);
        return block.timestamp < endTrainingDate;
    }
    function isInjured(bytes memory _g) internal view returns (bool){
        (,uint32 endInjuredDate,,)=LibGreyhound._getTrainedVar(_g);
        return block.timestamp < endInjuredDate;
    }
    function inRace(bytes memory _g) internal view returns (bool){
        return block.timestamp < LibGreyhound._getEndRaceDate(_g);
    }
    function isPregnant(bytes memory _g) internal view returns (bool){
        (,uint32 endPregnantDate)=LibGreyhound._getPregnant(_g);
        return block.timestamp + (60*60*24*7) < endPregnantDate;
    }
    function canRace(bytes memory _g) internal view returns (bool){
        return  !isChild(_g) && 
                LibGreyhound._getCurrentRaces(_g)<LibGreyhound._getMaxRaces(_g) &&
                !isPregnant(_g) &&
                !inRace(_g) &&
                !inTraining(_g) &&
                !isInjured(_g);
    }
    function canBreed(bytes memory _g) internal view returns (bool){
        (uint8 numPregnant,uint32 endPregnantDate)=LibGreyhound._getPregnant(_g);
        return  !isChild(_g) && 
                !isInjured(_g) &&
                numPregnant < 6 &&
                block.timestamp > endPregnantDate;
    }
    function canTrain(bytes memory _g, uint _hours, uint maxHours) internal view returns (bool){
        require(_hours>0,"Can't Train less than one hour");
        (,,uint8 hoursTrained,)=LibGreyhound._getTrainedVar(_g);
        uint resetDate=LibGreyhound._getResetDate(_g);
        if(!isPregnant(_g) && !inRace(_g) && !inTraining(_g) && !isInjured(_g)){
            if(hoursTrained+_hours<=maxHours && resetDate>block.timestamp){
                return true;
            }else{
                if(resetDate<block.timestamp && _hours<=maxHours){
                    return true;
                }
            }
        }
        return false;
    }
}