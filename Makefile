-include .env

.PHONY: all test deploy local cast call

install :
		forge install foundry-rs/forge-std && forge install Cyfrin/foundry-devops && forge install OpenZeppelin/openzeppelin-contracts && forge install dmfxyz/murky


#Merkle tree creation
create-merkle-tree :
	forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle

#### LOCAL ####

local-test : 
		forge test

# Make sure anvil is running before execute deploy
local-deploy : 
		forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url $(LOC_RPC_URL) --private-key $(LOC_PRIVATE_KEY) --broadcast -vvvv

local-hash-message-and-sign :
	@HASHED_MESSAGE=$$(cast call ${LOC_MERCLE_ADDRESS} "getMessageHash(address,uint256)" ${LOC_PUBLIC_KEY} ${LOC_AMOUNT_TO_CLAIM} --rpc-url ${LOC_RPC_URL}); \
	echo "-----------------------------------"; \
	echo "Message Hash:      $$HASHED_MESSAGE"; \
	echo "-----------------------------------"; \
	MESSAGE_SIGNATURE=$$(cast wallet sign --no-hash $$HASHED_MESSAGE --private-key ${LOC_PRIVATE_KEY}); \
	echo "Message Signature: $$MESSAGE_SIGNATURE"; \
	echo "-----------------------------------"

local-interact-claim :
	@forge script script/Interact.s.sol:ClaimAirdrop --rpc-url ${LOC_RPC_URL} --private-key ${LOC_PRIVATE_KEY}

#### SEPOLIA ####

sepolia-test : 
		forge test --fork-url $(ETH_SEPOLIA_RPC_URL)

# In order to import a wallet with Private Key -> cast wallet import my-sepolia-account --interactive
# --delay 60 -> gives enough time for contract verification. If free RPC provider is used, you might need to use --slow insted of --delay 60.
# with my-sepolia-account
sepolia-deploy :
		@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url $(ETH_SEPOLIA_RPC_URL) --account my-sepolia-account --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --slow -vvvv

# get signature for my-sepolia-account
sepolia-hash-message-and-sign :
	@HASHED_MESSAGE=$$(cast call ${SEPOLIA_MERCLE_ADDRESS} "getMessageHash(address,uint256)" ${SEPOLIA_PUBLIC_KEY} ${SEPOLIA_AMOUNT_TO_CLAIM} --rpc-url ${ETH_SEPOLIA_RPC_URL}); \
	echo "-----------------------------------"; \
	echo "Message Hash:      $$HASHED_MESSAGE"; \
	echo "-----------------------------------"; \
	MESSAGE_SIGNATURE=$$(cast wallet sign --no-hash $$HASHED_MESSAGE --account my-sepolia-account); \
	echo "Message Signature: $$MESSAGE_SIGNATURE"; \
	echo "-----------------------------------"

# with my-sepolia-account-2, claim for my-sepolia-account
sepolia-interact-claim :
	@forge script script/Interact.s.sol:ClaimAirdrop --rpc-url ${ETH_SEPOLIA_RPC_URL} --account my-sepolia-account-2 --broadcast -vvvv