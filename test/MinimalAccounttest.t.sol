//SDPX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "../script/DeployMinimalAccount.s.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendUserOps} from "../script/SendUserOps.s.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MinimalAccounttest is Test {
    MinimalAccount minimalAccount;
    DeployMinimalAccount deployMinimalAccount;
    ERC20Mock usdc;

    uint256 AMOUNT = 100e18;
    SendUserOps sendUserOps;
    address entryPoint;
    address io10;
    uint256 io10Pk;

    modifier makeio10() {
        (io10, io10Pk) = makeAddrAndKey("io10");
        vm.deal(io10, 100 ether);
        console.log(io10Pk);
        _;
    }

    function setUp() public {
        deployMinimalAccount = new DeployMinimalAccount();
        minimalAccount = deployMinimalAccount.run();
        usdc = new ERC20Mock();
        sendUserOps = new SendUserOps();
        entryPoint = deployMinimalAccount.getactiveentrypoint();
    }

    function test_ownercanexecutefunction() public makeio10 {
        address dest = address(usdc);
        uint256 value = 0;

        bytes memory functdata = abi.encodeWithSignature(
            "mint(address,uint256)",
            io10,
            AMOUNT
        );
        vm.prank(io10);
        minimalAccount.execute(dest, value, functdata);
        assertEq(usdc.balanceOf(io10), AMOUNT);
    }

    function test_RevertExecuteIf_notowner() public makeio10 {
        address dest = address(usdc);
        uint256 value = 0;

        bytes memory functdata = abi.encodeWithSignature(
            "mint(address,uint256)",
            io10,
            AMOUNT
        );
        vm.prank(vm.addr(2));
        vm.expectRevert(MinimalAccount.MinimalAccount__Unauthorized.selector);
        minimalAccount.execute(dest, value, functdata);
    }

    function test_signatureinsenduseropscanbevaildatedcorrectly()
        public
        makeio10
    {
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functdata = abi.encodeWithSignature(
            "mint(address,uint256)",
            io10,
            AMOUNT
        );
        bytes memory callData = abi.encodeWithSignature(
            "execute(address,uint256,bytes)",
            dest,
            value,
            functdata
        );
        sendUserOps.getsignedpackeduseroperation(
            address(minimalAccount),
            callData,
            entryPoint
        );
        PackedUserOperation memory userOp = sendUserOps
            .getsignedpackeduseroperation(
                address(minimalAccount),
                callData,
                entryPoint
            );
        bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);
        address signer = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(userOpHash),
            userOp.signature
        );

        assertEq(signer, io10);
    }

    function test_handleOps() public makeio10 {
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functdata = abi.encodeWithSignature(
            "mint(address,uint256)",
            io10,
            AMOUNT
        );
        bytes memory callData = abi.encodeWithSignature(
            "execute(address,uint256,bytes)",
            dest,
            value,
            functdata
        );
        PackedUserOperation memory userOp = sendUserOps
            .getsignedpackeduseroperation(
                address(minimalAccount),
                callData,
                entryPoint
            );
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = userOp;
        address user2 = vm.addr(2);
        address payable user2Payable = payable(user2);
        vm.prank(io10);
        IEntryPoint(entryPoint).depositTo{value: 10 ether}(
            address(minimalAccount)
        );

        vm.startPrank(user2);
        IEntryPoint(entryPoint).handleOps(ops, user2Payable);
        vm.stopPrank();

        assertEq(usdc.balanceOf(io10), AMOUNT);
    }
}
