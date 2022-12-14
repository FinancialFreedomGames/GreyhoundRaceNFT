// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { GreyhoundRace } from "../Libraries/GreyhoundRaceDiamondStorage.sol";
interface IDiamondLoupe {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }
    function facets() external view returns (Facet[] memory facets_);
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);
    function facetAddresses() external view returns (address[] memory facetAddresses_);
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract DiamondLoupeFacet is IDiamondLoupe, IERC165 {
    /// @notice Gets all facets and their selectors.
    /// @return facets_ Facet
    function facets() external override view returns (Facet[] memory facets_) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        uint numFacets = ds.facetAddresses.length;
        facets_ = new Facet[](numFacets);
        uint i;
        while(i<numFacets){
            address facetAddress_ = ds.facetAddresses[i];
            facets_[i].facetAddress = facetAddress_;
            facets_[i].functionSelectors = ds.facetFunctionSelectors[facetAddress_].functionSelectors;
            assembly{
                i := add(i,1)
            }
        }
    }

    /// @notice Gets all the function selectors provided by a facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external override view returns (bytes4[] memory facetFunctionSelectors_) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        facetFunctionSelectors_ = ds.facetFunctionSelectors[_facet].functionSelectors;
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external override view returns (address[] memory facetAddresses_) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        facetAddresses_ = ds.facetAddresses;
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external override view returns (address facetAddress_) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        facetAddress_ = ds.selectorToFacetAndPosition[_functionSelector].facetAddress;
    }

    // This implements ERC-165.
    function supportsInterface(bytes4 _interfaceId) external override view returns (bool) {
        GreyhoundRace.DiamondStorage storage ds = GreyhoundRace.diamondStorage();
        return ds.supportedInterfaces[_interfaceId];
    }
    function getSelectors() external pure returns(bytes4[] memory selector){
        selector=new bytes4[](5);
        selector[0]=this.facets.selector;
        selector[1]=this.facetFunctionSelectors.selector;
        selector[2]=this.facetAddresses.selector;
        selector[3]=this.facetAddress.selector;
        selector[4]=this.supportsInterface.selector;
    }
}