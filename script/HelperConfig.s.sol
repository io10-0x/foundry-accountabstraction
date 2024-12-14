//SDPX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address entryPoint;
    }
    NetworkConfig public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getsepoliaconfig();
        } else if (block.chainid == 31337) {
            activeConfig = getanvilconfig();
        } else if (block.chainid == 300) {
            activeConfig = getzksyncsepoliaconfig();
        }
    }

    function getsepoliaconfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(0x0576a174D229E3cFA37253523E645A78A0C91B57);
    }

    function getanvilconfig() public returns (NetworkConfig memory) {
        //deploy entry point mock
        EntryPoint entryPoint = new EntryPoint();
        return NetworkConfig(address(entryPoint));
    }

    function getzksyncsepoliaconfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig(address(0));
    }

    function getactiveentrypoint() public view returns (address) {
        return activeConfig.entryPoint;
    }
}
