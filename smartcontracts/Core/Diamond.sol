// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }
    function diamondCut(FacetCut[] calldata _diamondCut,address _init,bytes calldata _calldata) external;
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
interface IFacet {
    function getSelectors() external pure returns(bytes4[] memory selectors);
    function initialize() external;
}

contract Diamond {    

    constructor(address _contractOwner) payable { 
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        ds.permitedAddress[_contractOwner] = true;
    }
    // Generate cut of facets this is only useful if facet has the method getSelectors() implemented
    function generateCut(address _facet,IDiamondCut.FacetCutAction _mode) private pure returns(bytes memory bCut){
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0]=IDiamondCut.FacetCut({
            facetAddress: _facet, 
            action: _mode, 
            functionSelectors: IFacet(_facet).getSelectors()
        });
        bCut=abi.encode(cut);
    }
    // Easy add facet
    function addFacet(address _facet) external {
        GreyhoundRace.whenPermited();
        bytes memory _cut=generateCut(_facet,IDiamondCut.FacetCutAction.Add);
        GreyhoundRace.diamondCut(_cut,address(0),"");
    }
    // Easy update facet
    function updateFacet(address _facet) external {
        GreyhoundRace.whenPermited();
        bytes memory _cut=generateCut(_facet,IDiamondCut.FacetCutAction.Replace);
        GreyhoundRace.diamondCut(_cut,address(0),"");
    }
    // Easy remove facet
    function removeFacet(address _facet) external {
        GreyhoundRace.whenPermited();
        bytes memory _cut=generateCut(_facet,IDiamondCut.FacetCutAction.Remove);
        GreyhoundRace.diamondCut(_cut,address(0),"");
    }
    // Initialize facet if need to write data on diamondStorage
    function initializeFacet(address _facet) external {
        GreyhoundRace.whenPermited();
        (bool success,)=_facet.delegatecall(abi.encodeWithSelector(IFacet.initialize.selector));
        require(success, "Can't initialize facet");
    }
    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        GreyhoundRace.DiamondStorage storage ds;
        bytes32 position = GreyhoundRace.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}