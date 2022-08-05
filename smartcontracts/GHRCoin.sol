// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GHRCoin is ERC20 {
    address public marketingWallet=0x8Af07E03b70A6f9e323569CBC90De5f81e02dda7;
    mapping (address => bool) public permitedAddress;
    constructor() ERC20("GHRCoin", "GHR") {
        permitedAddress[msg.sender]=true;
        permitedAddress[marketingWallet]=true;
        _mint(marketingWallet, 100000);
    }
    modifier whenPermited() {
        require(permitedAddress[msg.sender],"Not permited");
        _;
    }
    function setPermitedAddress(address ad, bool permited) public whenPermited {
        permitedAddress[ad]=permited;
    }
    function decimals() public override pure returns (uint8) {
        return 0;
    }
    function _beforeTokenTransfer(address from,address to,uint256 amount) internal override {
        require(permitedAddress[from] || permitedAddress[to],"Not permited");
    }
}