// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title BagelToken
 * @author Metodiy Kozhuharov
 * @notice ERC20 ownable token, used by Airdrop for claming tokens.
 */
contract BagelToken is ERC20, Ownable {
    ////////////////////////////
    // Functions
    ////////////////////////////
    constructor() ERC20("Bagel Token", "BT") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
