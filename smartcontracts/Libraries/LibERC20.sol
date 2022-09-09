// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library LibERC20 {

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'LibIERC20: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'LibIERC20: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'LibIERC20: TRANSFER_FROM_FAILED');
    }

    function safeTransferNative(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function safeBalanceOf(address token,address account) internal view returns (uint256) {
        (bool success, bytes memory data)=token.staticcall(abi.encodeWithSelector(0x70a08231, account));
        require(success && data.length >= 32, 'LibIERC20: BALANCE_OF_FAILED');
        return abi.decode(data, (uint256));
    }

    function safeDecimals(address token) internal view returns (uint256) {
        (bool success, bytes memory data)=token.staticcall(abi.encodeWithSelector(0x313ce567));
        require(success && data.length >= 32, 'LibIERC20: DECIMAL_OF_FAILED');
        return abi.decode(data, (uint256));
    }
}