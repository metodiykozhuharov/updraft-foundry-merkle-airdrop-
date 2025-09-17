// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {Test, console} from "forge-std/Test.sol";

import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

/**
 * @dev change ROOT, proofOne, proofTwo once new merkle tree is generated
 * Testes with Anvil address -> 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D generated from (user, userPk) = makeAddrAndKey("user");
 */
contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;
    address gasPayer;
    address user;
    uint256 userPk;

    uint256 amountToCollect = (25 * 1e18); // 25.000000
    // 4 users, 25 tokens each
    uint256 amountToSend = amountToCollect * 4;

    bytes32 public ROOT =
        0xc8840e5733540932dd118fc49a1977edaab1a8d5b429c066a4a56c49df390c7c;
    bytes32 proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo =
        0x17ef837b1e83c73683e3b72a0a1a14ad62ef37b0ac34b8ac9b866548fc43f9f6;

    bytes32[] proof = [proofOne, proofTwo];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            // Owner mints the tokens
            token.mint(token.owner(), amountToSend);
            // Owner transfer the tokens to the airdrop
            token.transfer(address(airdrop), amountToSend);
        }

        gasPayer = makeAddr("gasPayer");
        (user, userPk) = makeAddrAndKey("user");
    }

    function signMessage(
        uint256 privKey,
        address account
    ) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessage = airdrop.getMessageHash(
            account,
            amountToCollect
        );
        (v, r, s) = vm.sign(privKey, hashedMessage);
    }

    function testUsersCanClaim() public {
        // Arrange
        uint256 startingBalance = token.balanceOf(user);
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPk, user);
        vm.stopPrank();

        // Act
        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: %d", endingBalance);

        // Assert
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
