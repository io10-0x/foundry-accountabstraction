//SDPX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {BaseAccount} from "lib/account-abstraction/contracts/core/BaseAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccount is BaseAccount, Ownable {
    error MinimalAccount__ExecutionFailed();
    error MinimalAccount__Unauthorized();

    uint256 private SIG_VALIDATION_SUCCESS = 0;
    uint256 private SIG_VALIDATION_FAILED = 1;
    address private entryPointAddress;

    constructor(address entrypointaddress) Ownable(msg.sender) {
        entryPointAddress = entrypointaddress;
    }

    modifier onlyOwnerorentrypoint() {
        if (msg.sender != owner() && msg.sender != address(entryPoint())) {
            revert MinimalAccount__Unauthorized();
        }
        _;
    }

    function entryPoint() public view override returns (IEntryPoint) {
        IEntryPoint entrypoint = IEntryPoint(entryPointAddress);
        return entrypoint;
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata functdata
    ) external onlyOwnerorentrypoint {
        (bool success, ) = dest.call{value: value}(functdata);
        if (!success) {
            revert MinimalAccount__ExecutionFailed();
        }
    }

    receive() external payable {}

    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view override returns (uint256 validationData) {
        bytes32 eip191MessageHash = MessageHashUtils.toEthSignedMessageHash(
            userOpHash
        );
        address signer = ECDSA.recover(eip191MessageHash, userOp.signature);
        if (signer != userOp.sender) {
            return SIG_VALIDATION_SUCCESS;
        }
        return SIG_VALIDATION_FAILED;
    }
}
