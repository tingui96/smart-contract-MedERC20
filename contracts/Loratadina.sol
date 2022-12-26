// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.18;

import "./MedERC20.sol";

contract Loratadina is MedERC20
{
    uint256 private constant INITIAL_SUPPLY = 100000000;

    constructor() MedERC20("Loratadina","LTD")
    {
        _mint(msg.sender,INITIAL_SUPPLY); 
    }
}
