//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Zkminimalaccount} from "../../src/zksync/Zkminimalaccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Transaction} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {INonceHolder} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/INonceHolder.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT, BOOTLOADER_FORMAL_ADDRESS} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import {MemoryTransactionHelper} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {ACCOUNT_VALIDATION_SUCCESS_MAGIC} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import {BootloaderUtilities} from "lib/foundry-era-contracts/src/system-contracts/contracts/BootloaderUtilities.sol";

contract ZkMinimalAccounttests is Test {
    Zkminimalaccount zkminimalaccount;
    ERC20Mock usdc;
    address io10;
    uint256 io10Pk;

    modifier makeio10() {
        (io10, io10Pk) = makeAddrAndKey("io10");
        vm.deal(io10, 100 ether);
        console.log(io10Pk);
        _;
    }

    function setUp() public makeio10 {
        vm.startPrank(io10);
        zkminimalaccount = new Zkminimalaccount();
        usdc = new ERC20Mock();
        vm.stopPrank();
    }

    function test_ownercanexecutefunctionzksync() public makeio10 {
        address dest = address(usdc);
        uint256 value = 0;
        vm.startPrank(io10);
        bytes memory functdata = abi.encodeWithSignature(
            "mint(address,uint256)",
            address(this),
            100e18
        );
        uint256 nonce = INonceHolder(NONCE_HOLDER_SYSTEM_CONTRACT).getMinNonce(
            address(zkminimalaccount)
        );

        Transaction memory transaction = _getunsignedtransaction(
            113,
            address(zkminimalaccount),
            dest,
            value,
            nonce,
            functdata
        );
        zkminimalaccount.executeTransaction("", "", transaction);
        vm.stopPrank();
    }

    function _getunsignedtransaction(
        uint256 txType,
        address from,
        address dest,
        uint256 value,
        uint256 nonce,
        bytes memory functdata
    ) internal pure returns (Transaction memory) {
        bytes32[] memory factoryDeps = new bytes32[](0);
        return
            Transaction({
                txType: txType,
                from: uint256(uint160(from)),
                to: uint256(uint160(dest)),
                gasLimit: 16777216,
                gasPerPubdataByteLimit: 16777216,
                maxFeePerGas: 16777216,
                maxPriorityFeePerGas: 16777216,
                paymaster: 0,
                nonce: nonce,
                value: value,
                reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
                data: functdata,
                signature: hex"",
                factoryDeps: factoryDeps,
                paymasterInput: hex"",
                reservedDynamic: hex""
            });
    }

    function test_transactioncanbevalidatedsuccessfully() public makeio10 {
        address dest = address(usdc);
        uint256 value = 0;
        vm.startPrank(io10);
        bytes memory functdata = abi.encodeWithSignature(
            "mint(address,uint256)",
            address(this),
            100e18
        );
        uint256 nonce = INonceHolder(NONCE_HOLDER_SYSTEM_CONTRACT).getMinNonce(
            address(zkminimalaccount)
        );

        Transaction memory transaction = _getunsignedtransaction(
            113,
            address(zkminimalaccount),
            dest,
            value,
            nonce,
            functdata
        );
        console.log(transaction.from);

        bytes32 resulthash = MemoryTransactionHelper.encodeHash(transaction);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            39190447143494087017456517568452700448528624742856304729136288545154424159060,
            resulthash
        );
        transaction.signature = abi.encodePacked(r, s, v);
        vm.stopPrank();
        vm.startPrank(BOOTLOADER_FORMAL_ADDRESS);
        vm.deal(address(zkminimalaccount), 100 ether);
        bytes4 magic = zkminimalaccount.validateTransaction(
            "",
            "",
            transaction
        );
        vm.stopPrank();
        assertEq(magic, ACCOUNT_VALIDATION_SUCCESS_MAGIC);
    }
}
