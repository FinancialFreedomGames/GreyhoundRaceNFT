// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
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

library GreyhoundRace {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("greyhoundrace.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct dataNFT {
        string _object;
        bytes _data;
    }

    struct FacetERC721 {
        // Token name
        string _name;
        // Token symbol
        string _symbol;
        // Mapping from token ID to owner address
        mapping(uint256 => address) _owners;
        // Mapping owner address to token count
        mapping(address => uint256) _balances;
        // Mapping from token ID to approved address
        mapping(uint256 => address) _tokenApprovals;
        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;
        // Mapping from owner to list of owned token IDs
        mapping(address => mapping(uint256 => uint256)) _ownedTokens;
        // Mapping from token ID to index of the owner tokens list
        mapping(uint256 => uint256) _ownedTokensIndex;
        // Array with all token ids, used for enumeration
        uint256[] _allTokens;
        // Mapping from token id to position in the allTokens array
        mapping(uint256 => uint256) _allTokensIndex;
        // Counter
        uint _counter;
        // Mapping to know quantity by object
        mapping(string => uint256) _counterByObject;
        // Mapping from token ID to data
        mapping(uint256 => dataNFT) _allTokensData;
    }
    
    

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface. Implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // address permited to use the contract
        mapping(address => bool) permitedAddress;
        // coin used in all ecosystem, default USDC
        address coin;
        // address on whitelist
        mapping(address => bool) whitelist;
        // NFTs
        FacetERC721 nftsData;
    }
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
    function setPermitedAddress(address ad, bool permited) internal {
        DiamondStorage storage ds = diamondStorage();
        whenPermited();
        ds.permitedAddress[ad]=permited;
    }
    function whenPermited() internal view {
        require(diamondStorage().permitedAddress[msg.sender],"Diamond: Address not permited");
    }
    function coinAddress() internal view returns(address coin){
        coin=diamondStorage().coin;
    }
    function randomNum(uint _mod) internal view returns (uint _randomNum) {
        assembly{
            let ptr := mload(0x40) //free memory pointer
            mstore(ptr,add(add(add(add(add(add(add(difficulty(),timestamp()),basefee()),gaslimit()),gasprice()),gas()),caller()),coinbase()))
            _randomNum := mod(keccak256(ptr, add(ptr, 32)) , _mod)
        }
    }
    // Internal function version of diamondCut
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);
    function diamondCut(bytes memory _data,address _init,bytes memory _calldata) internal {
        IDiamondCut.FacetCut[] memory _diamondCut=abi.decode(_data,(IDiamondCut.FacetCut[]));
        uint end=_diamondCut.length;
        uint i;
        while(i<end){
            IDiamondCut.FacetCutAction action = _diamondCut[i].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[i].facetAddress, _diamondCut[i].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[i].facetAddress, _diamondCut[i].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[i].facetAddress, _diamondCut[i].functionSelectors);
            } else {
                revert("DiamondCut: Incorrect FacetCutAction");
            }
            assembly{
                i := add(i,1)
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "DiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();        
        require(_facetAddress != address(0), "DiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);            
        }
        uint end=_functionSelectors.length;
        uint i;
        while(i<end){
            bytes4 selector = _functionSelectors[i];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "DiamondCut: Can't add function that already exists");
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
            assembly{
                i := add(i,1)
            }
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "DiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "DiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        uint end=_functionSelectors.length;
        uint i;
        while(i<end){
            bytes4 selector = _functionSelectors[i];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress != _facetAddress, "DiamondCut: Can't replace function with same function");
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
            assembly{
                i := add(i,1)
            }
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "DiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(_facetAddress == address(0), "DiamondCut: Remove facet address must be address(0)");
        uint end=_functionSelectors.length;
        uint i;
        while(i<end){
            bytes4 selector = _functionSelectors[i];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
            assembly{
                i := add(i,1)
            }
        }
    }

    function addFacet(DiamondStorage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "DiamondCut: New facet has no code");
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds.facetAddresses.length;
        ds.facetAddresses.push(_facetAddress);
    }    


    function addFunction(DiamondStorage storage ds, bytes4 _selector, uint96 _selectorPosition, address _facetAddress) internal {
        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(DiamondStorage storage ds, address _facetAddress, bytes4 _selector) internal {        
        require(_facetAddress != address(0), "DiamondCut: Can't remove function that doesn't exist");
        // an immutable function is a function defined directly in a diamond
        require(_facetAddress != address(this), "DiamondCut: Can't remove immutable function");
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "DiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "DiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "DiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("DiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        require(isContract(_contract), _errorMessage);
    }
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}