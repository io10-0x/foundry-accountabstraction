//SDPX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SendUserOps is Script {
    function getsignedpackeduseroperation(
        address smartcontractaccount,
        bytes calldata callDatabytes,
        address entrypointaddress
    ) external view returns (PackedUserOperation memory) {
        uint256 nonceval = IEntryPoint(entrypointaddress).getNonce(
            smartcontractaccount,
            0
        );
        console.log(nonceval);
        PackedUserOperation memory userOp = _getunsignedpackeduseroperation(
            smartcontractaccount,
            nonceval,
            callDatabytes
        );
        bytes32 userOpHash = IEntryPoint(entrypointaddress).getUserOpHash(
            userOp
        );
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            39190447143494087017456517568452700448528624742856304729136288545154424159060,
            digest
        );
        userOp.signature = abi.encodePacked(r, s, v);

        return userOp;
    }

    function _getunsignedpackeduseroperation(
        address smartcontractaccount,
        uint256 nonce,
        bytes calldata callDatabytes
    ) internal pure returns (PackedUserOperation memory) {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: smartcontractaccount,
            nonce: nonce,
            initCode: hex"",
            callData: callDatabytes,
            accountGasLimits: bytes32(
                (uint256(verificationGasLimit) << 128) | callGasLimit
            ),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(
                (uint256(maxPriorityFeePerGas) << 128) | maxFeePerGas
            ),
            paymasterAndData: hex"",
            signature: hex""
        });
        return userOp;
    }
}
