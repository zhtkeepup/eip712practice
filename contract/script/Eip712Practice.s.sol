// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Eip712Practice} from "../src/Eip712Practice.sol";

contract Eip712PracticeScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        Eip712Practice c = new Eip712Practice();

        // vm.stopBroadcast();
    }
}
