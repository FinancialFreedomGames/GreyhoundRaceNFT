// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library LibGreyhound {
    struct Greyhound{
        string name;
        uint32 bornDate;
        uint256 dad;
        uint256 mom;
        uint16 currentRaces;
        uint16 maxRaces;
        uint8 rarity;
        uint16 speed;
        uint16 strength;
        uint16 agility;
        uint16 reaction_time;
        uint16 endurance;
        uint16 exp_speed;
        uint16 exp_strength;
        uint16 exp_agility;
        uint16 exp_reaction_time;
        uint16 exp_endurance;
        bool isMale;
        uint8 num_pregnant;
        uint32 endPregnantDate;
        uint32 endTrainingDate;
        uint32 endInjuredDate;
        uint8 hoursTrained;
        uint8 consecutiveTraining;
        uint32 endRaceDate;
        uint16 consecutiveRaces;
        bytes3 color;
        uint32 resetDate;
    }
    function isValid(string memory _object) internal pure returns (bool){
        return keccak256(abi.encodePacked(_object)) == keccak256("greyhound");
    }
    function encode(Greyhound memory g) internal pure returns(bytes memory) {
        return abi.encodePacked(
            _encodeBase(g),
            _encodeAttributesAndExperiences(g),
            _encodeGender(g),
            _encodeTraining(g),
            g.endRaceDate,
            g.consecutiveRaces,
            g.color,
            g.resetDate
        );
    }
    function _encodeBase(Greyhound memory g) internal pure returns(bytes memory) {
        return abi.encodePacked(
            g.name,
            g.bornDate,
            g.dad,
            g.mom,
            g.currentRaces,
            g.maxRaces,
            g.rarity
        );
    }
    function _encodeAttributesAndExperiences(Greyhound memory g) internal pure returns(bytes memory) {
        return abi.encodePacked(
            g.speed,
            g.strength,
            g.agility,
            g.reaction_time,
            g.endurance,
            g.exp_speed,
            g.exp_strength,
            g.exp_agility,
            g.exp_reaction_time,
            g.exp_endurance
        );
    }
    function _encodeTraining(Greyhound memory g) internal pure returns(bytes memory) {
        return abi.encodePacked(
            g.endTrainingDate,
            g.endInjuredDate,
            g.hoursTrained,
            g.consecutiveTraining
        );
    }
    function _encodeGender(Greyhound memory g) internal pure returns(bytes memory) {
        return abi.encodePacked(
            g.isMale,
            g.num_pregnant,
            g.endPregnantDate
        );
    }
    function decode(bytes memory _g) internal pure returns(Greyhound memory g) {
        g.name=_getName(_g);
        g.bornDate=_getBornDate(_g);
        (g.dad,g.mom)=_getParents(_g);
        g.currentRaces=_getCurrentRaces(_g);
        g.maxRaces=_getMaxRaces(_g);
        g.rarity=_getRarity(_g);
        (g.speed,g.strength,g.agility,g.reaction_time,g.endurance,)=_getAttributes(_g);
        (g.exp_speed,g.exp_strength,g.exp_agility,g.exp_reaction_time,g.exp_endurance)=_getExperience(_g);
        g.isMale=_isMale(_g);
        (g.num_pregnant,g.endPregnantDate)=_getPregnant(_g);
        (g.endTrainingDate,g.endInjuredDate,g.hoursTrained,g.consecutiveTraining)=_getTrainedVar(_g);
        g.endRaceDate=_getEndRaceDate(_g);
        g.consecutiveRaces=_getConsecutiveRaces(_g);
        g.color=bytes3(_getColor(_g));
        g.resetDate=_getResetDate(_g);
    }
    function _getResetDate(bytes memory _g) internal pure returns(uint32 resetDate){
        assembly{
            resetDate := shr(224,mload(add(add(_g, 32),138)))
        }
    }
    function _getColor(bytes memory _g) internal pure returns(uint24 color){
        assembly{
            color := shr(232,mload(add(add(_g, 32),135)))
        }
    }
    function _getConsecutiveRaces(bytes memory _g) internal pure returns(uint16 consecutiveRaces){
        assembly{
            consecutiveRaces := shr(240,mload(add(add(_g, 32),133)))
        }
    }
    function _getEndRaceDate(bytes memory _g) internal pure returns(uint32 endRaceDate){
        assembly{
            endRaceDate := shr(224,mload(add(add(_g, 32),129)))
        }
    }
    function _getTrainedVar(bytes memory _g) internal pure returns(uint32 endTrainingDate,uint32 endInjuredDate,uint8 hoursTrained,uint8 consecutiveTraining){
        assembly{
            let offset := add(_g, 32)
            endTrainingDate := shr(224,mload(add(offset,119)))
            endInjuredDate := shr(224,mload(add(offset,123)))
            hoursTrained := shr(248,mload(add(offset,127)))
            consecutiveTraining := shr(248,mload(add(offset,128)))
        }
    }
    function _getPregnant(bytes memory _g) internal pure returns(uint8 numPregnant,uint32 endPregnantDate){
        assembly{
            let offset := add(_g, 32)
            numPregnant := shr(248,mload(add(offset,114)))
            endPregnantDate := shr(224,mload(add(offset,115)))
        }
    }
    function _isMale(bytes memory _g) internal pure returns(bool male){
        assembly{
            male := shr(248,mload(add(add(_g, 32),113)))
        }
    }
    function _getExperience(bytes memory _g) internal pure returns(uint16 speed,uint16 strength,uint16 agility,uint16 reaction_time,uint16 endurance){
        assembly{
            let offset := add(_g, 32)
            speed := shr(240,mload(add(offset,103)))
            strength := shr(240,mload(add(offset,105)))
            agility := shr(240,mload(add(offset,107)))
            reaction_time := shr(240,mload(add(offset,109)))
            endurance := shr(240,mload(add(offset,111)))
        }
    }
    function _getAttributes(bytes memory _g) internal pure returns(uint16 speed,uint16 strength,uint16 agility,uint16 reaction_time,uint16 endurance,uint sum){
        assembly{
            let offset := add(_g, 32)
            speed := shr(240,mload(add(offset,93)))
            strength := shr(240,mload(add(offset,95)))
            agility := shr(240,mload(add(offset,97)))
            reaction_time := shr(240,mload(add(offset,99)))
            endurance := shr(240,mload(add(offset,101)))
            sum := add(add(add(add(speed,strength),agility),reaction_time),endurance)
        }
    }
    function _getRarity(bytes memory _g) internal pure returns(uint8 rarity){
        assembly{
            rarity := shr(248,mload(add(add(_g, 32),92)))
        }
    }
    function _getMaxRaces(bytes memory _g) internal pure returns(uint16 maxRaces){
        assembly{
            maxRaces := shr(240,mload(add(add(_g, 32),90)))
        }
    }
    function _getCurrentRaces(bytes memory _g) internal pure returns(uint16 currentRaces){
        assembly{
            currentRaces := shr(240,mload(add(add(_g, 32),88)))
        }
    }
    function _getParents(bytes memory _g) internal pure returns(uint256 dad, uint256 mom){
        assembly{
            let offset := add(_g, 32)
            dad := mload(add(offset,24))
            mom := mload(add(offset,56))
        }
    }
    function _getBornDate(bytes memory _g) internal pure returns(uint32 bornDate){
        assembly{
            bornDate := shr(224,mload(add(add(_g, 32),20)))
        }
    }
    function _getName(bytes memory _g) internal pure returns(string memory){
        bytes20 name;
        assembly{
            name := shl(96,shr(96,mload(add(_g,32))))
        }
        return string(abi.encodePacked(name));
    }
}