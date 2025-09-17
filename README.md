# 🏗️ Foundry Merkle Airdrop

[⭐️ Updraft Advance Foundry | Merkle Airdrop](https://updraft.cyfrin.io/courses/advanced-foundry/merkle-airdrop/introduction)

## 📖 About  
This project is a collection of smart contracts that demonstrate **token mechanics, access control, and distribution patterns**.  

It includes:  
- An **ERC20-based token**  
- A **Merkle Airdrop contract** for efficient distribution  
- Supporting **contracts and scripts** for interaction and automation  

The goal is to explore how to combine standards like **ERC20, EIP-712, and Merkle proofs** into a secure, gas-efficient system for token minting, claiming, and transfers.

⚠️ This is an **educational project**, and the code is adapted from course materials for learning purposes.


## ✅ Proof of Execution  

- [Contract: Bagel Token (ERC20 token)](https://sepolia.etherscan.io/address/0x5a1c873bffb9a0236175e5586ff2cdccacae2f55)  
- [Contract: Merkle Airdrop](https://sepolia.etherscan.io/address/0x47cc83d93092e16fe95c7ce84794934203c7f16f)  
  - Successful claim transaction: [View on Etherscan](https://sepolia.etherscan.io/tx/0xb7e5beb36a9aa4f60899f202ad188eb9127c08483f8cd5d50647684f167fe2bb)


## ⚙️ Setup  

```bash
git clone https://github.com/metodiykozhuharov/updraft-foundry-merkle-airdrop.git
cd updraft-foundry-merkle-airdrop 
make install
```

## 🔐 Environment Variables

Create a .env file in the project root with the following content:

```ini
# ------------------
# ---- Local -------
# ------------------

# Anvil Keys
LOC_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
LOC_PUBLIC_KEY=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

# RPC URL
LOC_RPC_URL=http://127.0.0.1:8545

# Contracts information
LOC_MERCLE_ADDRESS=<TO BE ADDED LATER IN THE SETUP>
LOC_TOKEN_ADDRESS=<TO BE ADDED LATER IN THE SETUP>
LOC_AMOUNT_TO_CLAIM=25000000000000000000

# ------------------
# ---- Sepolia -----
# ------------------

# Keys
SEPOLIA_PUBLIC_KEY=<TO BE ADDED LATER IN THE SETUP - the one for my-sepolia-account>

# RPC URLs
ETH_SEPOLIA_RPC_URL=<YOUR SEPOLIA RPC URL>

# Contracts created
SEPOLIA_MERCLE_ADDRESS=<TO BE ADDED LATER IN THE SETUP>
SEPOLIA_TOKEN_ADDRESS=<TO BE ADDED LATER IN THE SETUP>
SEPOLIA_AMOUNT_TO_CLAIM=25000000000000000000

# API Keys
ETHERSCAN_API_KEY=<YOUR ETHERSCAN API KEY>
```

⚠️ **Important:** Do not commit .env to git. Always use test accounts / fake ETH for local and Sepolia testing.


## 🌳 Merkle Tree Setup

1. Add 2 Sepolia addresses in GenerateInput.s.sol.
2. Create a new Merkle tree:
```bash
make create-merkle-tree
```
The generated tree will be available under:
script/target/output.json

## 🧪 Test

Update test configuration:
- DeployMerkleAirdrop.s.sol → set ROOT
- MerkleAirDropTest.t.sol → set ROOT, proofOne, proofTwo

Then run tests:
```bash
make local-test
make sepolia-test
```

## 🚀 Deploy & Interact

### 🔹 Local

```bash
# Step 1 (make sure anvil is running)
make local-deploy

# Step 2: Get contract addresses from Anvil and update .env. and then reload environment:
source .env

# Step 3: Hash message & sign:
make local-hash-message-and-sign

# Step 4: Update Interact.s.sol: Function setChainConfig()
make local-interact-claim
```

### 🔹 Sepolia

```bash
# Step 1: Import wallets:
cast wallet import my-sepolia-account --interactive
cast wallet import my-sepolia-account-2 --interactive

# Step 2: Deploy:
make sepolia-deploy

# Step 3: Get deployed contract addresses from Sepolia and update .env and then reload environment:
source .env

# Step 4: Hash message & sign:
make sepolia-hash-message-and-sign

# Step 5: Update Interact.s.sol: Function setChainConfig()
make sepolia-interact-claim
```
