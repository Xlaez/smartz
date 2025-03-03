// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAccountProxy {
    /**
     * @dev Initializes the proxy with a new implementation address.
     * @param implementation The address of the new implementation contract.
     */
    function initialize(address implementation) external;
}
