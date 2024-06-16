// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Eip712Practice} from "../src/Eip712Practice.sol";

contract TokenBankTest is Test {
    Eip712Practice public eip712Practice;

    address admin;

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
        uint256 nn1 = eip712Practice.number();

        permit = Eip712Practice.PermitData({
            signer: admin,
            message1: 778899,
            message2: 112233,
            nonce: 0
        });

        // hashing typed structured data
        bytes32 digest = eip712Practice.getTypedDataHash(permit);

        // signing with private key and typed data hash.
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(aPrivateKey, digest);

        // call smart contrat with signature
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

    function test_permit2DoSomething() public {
        vm.startPrank(admin);
        uint256 nn1 = eip712Practice.number();

        permit = Eip712Practice.PermitData({
            signer: admin,
            message1: 778899,
            message2: 112233,
            nonce: 0
        });

        // hashing typed structured data
        bytes32 digest = eip712Practice.getTypedDataHash(permit);

        // signing with private key and typed data hash.
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(aPrivateKey, digest);

        bytes memory signature = new bytes(65); // 65 bytes for ECDSA signature
        // Append r value
        assembly {
            mstore(add(signature, 0x20), r)
        }
        // Append s value
        assembly {
            mstore(add(signature, 0x40), s)
        }
        // Append v value
        signature[64] = bytes1(v); // Since v is a single byte, we can directly assign it
        console.logBytes(signature);
        // call smart contrat with signature
        eip712Practice.permit2DoSomething(
            permit.signer,
            permit.message1,
            permit.message2,
            signature
        );
        //
        uint256 nn2 = eip712Practice.number();
        assertEq(nn1 + 1, nn2);
        console.log("number,", nn1, nn2);
    }
}
