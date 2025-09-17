// SPDX-Licence-Indentifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

/**
 * @dev under function setChainCOnfig() -> change ROOT, proofOne, proofTwo and SIGNATURE once new merkle tree is generated
 * @dev once MerkleAirdrop is deployed, run "make local-hash-message-and-sign" to generate SIGNATURE - copy the result without 0x part at the beginning. Before run, make sure that you added the info to .env and source it.
 * @dev if merkle tree is changed, changes also in tests are required
 */
contract ClaimAirdrop is Script {
    error Interact__InvalidSignatureLength();

    uint256 amountToCollect = (25 * 1e18); // 25.000000
    // You need to use different inputs, depending ot which address you want to claim for.
    address claimingAddress;
    bytes32 proofOne;
    bytes32 proofTwo;
    bytes32[] mercleProof;
    bytes SIGNATURE;

    function claimAirdrop(address airdrop, address token) public {
        vm.startBroadcast();
        setChainCOnfig();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        uint256 startingBalance = BagelToken(token).balanceOf(claimingAddress);
        console.log("Starting balance: ", startingBalance);
        console.log("Claiming Airdrop");
        MerkleAirdrop(airdrop).claim(
            claimingAddress,
            amountToCollect,
            mercleProof,
            v,
            r,
            s
        );
        uint256 endingBalance = BagelToken(token).balanceOf(claimingAddress);
        vm.stopBroadcast();
        console.log("Ending balance: ", endingBalance);
        console.log("Claimed Airdrop");
    }

    // Does similar thing to the ECDSA.tryRecover()
    function splitSignature(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert Interact__InvalidSignatureLength();
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function setChainCOnfig() public {
        if (block.chainid == 11155111) {
            // !!! Bellow are Anvil config, change with Sepolia once you have them.
            claimingAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
            proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
            proofTwo = 0xf6d2cf372e8e9ea30adc76ce624188519aa84068e880197348f882194384cb22;
            mercleProof = [proofOne, proofTwo];
            SIGNATURE = hex"04209f8dfd0ef06724e83d623207ba8c33b6690e08772f8887a4eaf9a66b9182188938adea374fa542ad5ddde24bdc981f5e26a628e65fb425a68db8a938f6761c";
        } else {
            // Anvil config
            claimingAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
            proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
            proofTwo = 0x17ef837b1e83c73683e3b72a0a1a14ad62ef37b0ac34b8ac9b866548fc43f9f6;
            mercleProof = [proofOne, proofTwo];
            // without 0x part at the beginning
            SIGNATURE = hex"04209f8dfd0ef06724e83d623207ba8c33b6690e08772f8887a4eaf9a66b9182188938adea374fa542ad5ddde24bdc981f5e26a628e65fb425a68db8a938f6761c";
        }
    }

    function run() external {
        address mostRecentlyDeployedAirdrop = DevOpsTools
            .get_most_recent_deployment("MerkleAirdrop", block.chainid);
        address mostRecentlyDeployedToken = DevOpsTools
            .get_most_recent_deployment("BagelToken", block.chainid);
        claimAirdrop(mostRecentlyDeployedAirdrop, mostRecentlyDeployedToken);
    }
}
