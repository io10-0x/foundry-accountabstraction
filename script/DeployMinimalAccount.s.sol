//SDPX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {Script, console} from "lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMinimalAccount is Script {
    address entryPoint;

    function run() public returns (MinimalAccount) {
        (address io10, ) = makeAddrAndKey("io10");
        vm.startBroadcast(io10);
        HelperConfig helperConfig = new HelperConfig();
        entryPoint = helperConfig.activeConfig();
        MinimalAccount minimalAccount = new MinimalAccount(entryPoint);

        vm.stopBroadcast();
        return minimalAccount;
    }

    function getactiveentrypoint() public view returns (address) {
        return entryPoint;
    }
}
