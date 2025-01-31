// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    address public owner;

    constructor(uint256 initialSupply) ERC20("OurToken", "OT") {
        owner = msg.sender;
        _mint(owner, initialSupply);
    }

    function mint(address account, uint256 value) public {
        if (owner != msg.sender) {
            revert();
        }

        _mint(account, value);
    }
}
