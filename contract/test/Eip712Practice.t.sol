// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Eip712Practice} from "../src/Eip712Practice.sol";

contract TokenBankTest is Test {
    Eip712Practice public eip712Practice;

    address admin;
    //
    uint8 v;
    bytes32 r;
    bytes32 s;

    uint256 aPrivateKey;

    Eip712Practice.PermitData permit;

    function setUp() public {
        aPrivateKey = 0x123456;
        admin = vm.addr(aPrivateKey);
        deal(admin, 100 ether);

        eip712Practice = new Eip712Practice();
    }

    function test_permitDoSomething() public {
        vm.startPrank(admin);

        permit = Eip712Practice.PermitData({
            signer: admin,
            message1: 778899,
            message2: "hello world!",
            nonce: 0
        });
        bytes32 digest = eip712Practice.getTypedDataHash(permit);

        (v, r, s) = vm.sign(aPrivateKey, digest);

        uint256 nn1 = eip712Practice.number();

        eip712Practice.permitDoSomething(
            permit.signer,
            permit.message1,
            permit.message2,
            v,
            r,
            s
        );
        //
        uint256 nn2 = eip712Practice.number();
        assertEq(nn1 + 1, nn2);
        console.log("number,", nn1, nn2);
    }
}
