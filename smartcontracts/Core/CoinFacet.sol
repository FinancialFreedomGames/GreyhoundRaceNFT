// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
contract CoinFacet {
    function setCoin(address _address) external {
        GreyhoundRace.whenPermited();
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.coin=_address;
    }
    function getCoin() external view returns(address coin) {
        coin=GreyhoundRace.coinAddress();
    }
    function initialize() external {
        GreyhoundRace.whenPermited();
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.coin=0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;//USDC address
    }
    function getSelectors() external pure returns(bytes4[] memory selector) {
        selector=new bytes4[](2);
        selector[0]=this.setCoin.selector;
        selector[1]=this.getCoin.selector;
    }
}