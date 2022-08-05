// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
contract DiamondCutFacet {
    enum FacetCutAction {Add, Replace, Remove}
    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(FacetCut[] memory _diamondCut,address _init,bytes calldata _calldata) external {
        GreyhoundRace.whenPermited();
        GreyhoundRace.diamondCut(abi.encode(_diamondCut), _init, _calldata);
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](1);
        selector[0]=this.diamondCut.selector;
    }
}