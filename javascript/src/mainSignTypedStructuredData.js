import {
  getContract,
  formatEther,
  parseEther,
  encodeAbiParameters,
  encodeFunctionData,
  keccak256,
} from "viem";

import { privateKeyToAccount } from "viem/accounts";

import { createPublicClient, http, createWalletClient } from "viem";
import { sepolia, mainnet, localhost } from "viem/chains";

import { abiPermit2DoSomething } from "./abi/Eip712PracticeAbi.js";

const walletClient = createWalletClient({
  chain: localhost,
  transport: http("http://127.0.0.1:8545"),
});

const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

const domain = {
  name: "Eip712Practice",
  version: "1",
  chainId: 1337, //
  verifyingContract: CONTRACT_ADDRESS, //,
};

const types = {
  eip712permit: [
    { name: "signer", type: "address" },
    { name: "message1", type: "uint256" },
    { name: "message2", type: "uint256" },
    { name: "nonce", type: "uint256" },
  ],
};

// this key is the first of "anvil's test key"
const privateKey =
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const account = privateKeyToAccount(privateKey);

async function signAuth(message1, message2, nonce) {
  const signature = await walletClient.signTypedData({
    account,
    domain,
    types,
    primaryType: "eip712permit",
    message: {
      signer: account.address,
      message1: message1,
      message2: message2,
      nonce: nonce,
    },
  });

  console.log("account.address:", account.address);
  // 0x744cef81591296eaf103706f0f4388d5284b3383fd3b087374ce90ecf13c05c82003bf9436cb29da6220beca227076e5e07bb03f8b49a71af98eccdc85bccd221b
  console.log("my-signature:", signature);
  return signature;
}

async function callContractToDoSomething2(nonce) {
  const signer = account.address;
  const message1 = 778899n;
  const message2 = 112233n;

  const signature = await signAuth(message1, message2, nonce);

  var encodedData;
  try {
    encodedData = encodeFunctionData({
      abi: abiPermit2DoSomething,
      functionName: "permit2DoSomething",
      args: [signer, message1, message2, signature],
    });

    const hash = await walletClient.sendTransaction({
      account: account,
      to: CONTRACT_ADDRESS,
      value: BigInt(0), // parseEther("0.0"),
      data: encodedData,
    });

    console.log(`call contract , signer=${signer}, hash=${hash}`);
    return hash;
  } catch (e) {
    console.log("call contract error:", e);
  }
}

async function main() {
  const nonce = 0; // the value of the nonce should be increased by 1 after each call
  await callContractToDoSomething2(nonce);
}

await main();
