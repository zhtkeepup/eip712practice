// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "../lib/openzeppelin-contracts/contracts/utils/Nonces.sol";

import {MessageHashUtils} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract Eip712Practice is EIP712, Nonces {
    struct PermitData {
        address signer;
        uint256 message1;
        uint256 message2;
        uint256 nonce;
    }

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            "eip712permit(address signer,uint256 message1,uint256 message2,uint256 nonce)"
        );

    string private constant SIGNING_DOMAIN_NAME = "Eip712Practice";
    string private constant SIGNING_DOMAIN_VERSION = "1";

    error ERC2612InvalidSigner(address signer, address owner);

    uint256 public number;

    constructor() EIP712(SIGNING_DOMAIN_NAME, SIGNING_DOMAIN_VERSION) {}

    /**
        generate hash by 5 element: 
        1.keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), (named TYPE_HASH)
        2. SIGNING_DOMAIN_NAME,
        3. SIGNING_DOMAIN_VERSION,
        4. block.chainid,
        5. address(this),
    */
    function domainSeparator() private view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function getTypedDataHash(
        PermitData memory _permit
    ) public view returns (bytes32) {
        return
            // same as:  keccak256(abi.encodePacked("\x19\x01",DOMAIN_SEPARATOR,keccak256(...)));
            MessageHashUtils.toTypedDataHash(
                domainSeparator(),
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        _permit.signer,
                        _permit.message1,
                        _permit.message2,
                        _permit.nonce
                    )
                )
            );
    }

    function eip712permit(
        address signer,
        uint256 message1,
        uint256 message2,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {
        PermitData memory pd = PermitData({
            signer: signer,
            message1: message1,
            message2: message2,
            nonce: _useNonce(signer)
        });

        bytes32 hash = getTypedDataHash(pd);

        address recoveredSigner = ECDSA.recover(hash, v, r, s);
        require(signer == recoveredSigner, "InvalidSigner.1.");
    }

    event DoSomething(address signer, uint256 message1, uint256 message2);

    function permitDoSomething(
        address signer,
        uint256 message1,
        uint256 message2,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        eip712permit(signer, message1, message2, v, r, s);
        // do something...
        number++;
        emit DoSomething(signer, message1, message2);
    }

    ///////////////////////

    function eip712permit2(
        address signer,
        uint256 message1,
        uint256 message2,
        bytes memory signature
    ) private {
        require(signature.length == 65, "Invalid signature.length");

        bytes32 r;
        bytes32 s;
        uint8 v;
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        /// @solidity memory-safe-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        eip712permit(signer, message1, message2, v, r, s);
    }

    function permit2DoSomething(
        address signer,
        uint256 message1,
        uint256 message2,
        bytes memory signature
    ) external {
        eip712permit2(signer, message1, message2, signature);
        // do something...
        number++;
        emit DoSomething(signer, message1, message2);
    }
}
