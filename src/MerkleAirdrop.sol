// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title MerkleAirdrop - Airdrop tokens to users who can prove they are in a merkle tree
 * @author Metodiy Kozhuharov
 * @notice
 */
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20; // Prevent sending tokens to recipients who can’t receive

    ////////////////////////////
    // Error Codes
    ////////////////////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed(address account);
    error MerkleAirdrop__InvalidSignature();

    ////////////////////////////
    // Type declarations
    ////////////////////////////
    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    ////////////////////////////
    // State variables
    ////////////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");

    ////////////////////////////
    // Events
    ////////////////////////////
    event MerkleAirdrop__Claim(
        address indexed _account,
        uint256 indexed _amount
    );

    ////////////////////////////
    // Functions
    ////////////////////////////
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("Merkle Airdrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    ////////////////////////////
    // Public & External
    ////////////////////////////
    function claim(
        address _account,
        uint256 _amount,
        bytes32[] calldata _mercleProof,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if (s_hasClaimed[_account]) {
            revert MerkleAirdrop__AlreadyClaimed(_account);
        }

        if (
            !_isValidSignature(
                _account,
                getMessageHash(_account, _amount),
                _v,
                _r,
                _s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Avoids collisions when hash twice
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(_account, _amount)))
        );

        if (!MerkleProof.verify(_mercleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[_account] = true;
        emit MerkleAirdrop__Claim(_account, _amount);

        i_airdropToken.safeTransfer(_account, _amount);
    }

    function getMessageHash(
        address _account,
        uint256 _amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: _account, amount: _amount})
                    )
                )
            );
    }

    ////////////////////////////
    // Internal & Private
    ////////////////////////////
    function _isValidSignature(
        address _account,
        bytes32 _digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(_digest, _v, _r, _s);
        return actualSigner == _account;
    }

    ////////////////////////////
    // View & Pure
    ////////////////////////////
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
