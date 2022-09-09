// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
contract WhitelistFacet {
    function includeOrExcludeInWhitelist(address[] memory _addresses,bool _include) external {
        GreyhoundRace.whenPermited();
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        uint end=_addresses.length;
        uint i;
        while(i<end){
            ds.whitelist[_addresses[i]]=_include;
            assembly{
                 i := add(i,1)
            }
        }
    }
    function inWhitelist(address _address) external view returns(bool) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.whitelist[_address];
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](2);
        selector[0]=this.includeOrExcludeInWhitelist.selector;
        selector[1]=this.inWhitelist.selector;
    }
}