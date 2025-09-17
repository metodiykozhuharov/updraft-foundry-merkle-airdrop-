// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {Script} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
 * @dev you need to change the ROOT each time new Merkle tree is generated
 */
contract DeployMerkleAirdrop is Script {
    bytes32 private ROOT =
        0xc8840e5733540932dd118fc49a1977edaab1a8d5b429c066a4a56c49df390c7c;
    // 4 users, 25 Bagel tokens each
    uint256 s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));
        // Owner mints the tokens
        token.mint(token.owner(), s_amountToTransfer);
        // Owner transfer the tokens to the airdrop
        IERC20(token).transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();

        return (airdrop, token);
    }

    function run() public returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
