// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.18;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./MedErc20.sol";

contract AspirinaToken is MedErc20
{
    uint256 private constant INITIAL_SUPPLY = 100000000;

    constructor() MedErc20(0,"Dipirona","DPN")
    {
        _mint(msg.sender,INITIAL_SUPPLY); 
    }
}
