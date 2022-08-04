// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
contract PermitedAddressFacet {
    function setPermitedAddress(address _address,bool _permited) external {
        GreyhoundRace.setPermitedAddress(_address,_permited);
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](1);
        selector[0]=this.setPermitedAddress.selector;
    }
}