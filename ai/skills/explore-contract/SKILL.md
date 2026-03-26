---
name: explore-contract
description: >-
  Deep-dive an on-chain smart contract: fetch source, decode storage layout, read key state,
  and trace recent interactions. Use when the user wants to understand a deployed contract.
disable-model-invocation: true
---

# Explore Contract

Perform a comprehensive investigation of a deployed smart contract. Takes a contract address
(and optionally a chain) via `$ARGUMENTS`.

## Parse Arguments

- `$ARGUMENTS` should contain at least a contract address (0x...).
- Optional: chain name or chain ID (default: the current `ETH_RPC_URL`, or Sepolia if unset).
- Example: `/explore-contract 0xAbC...123 mainnet`

## Investigation Steps

Run these in order, using the `foundry-cast` skill's conventions for RPC URLs:

### 1. Basic Info
```bash
cast code <address> --rpc-url "$ETH_RPC_URL"   # verify it's a contract
cast balance <address> --rpc-url "$ETH_RPC_URL"
cast nonce <address> --rpc-url "$ETH_RPC_URL"
```

### 2. Check for Proxy Pattern
```bash
# EIP-1967 implementation slot
cast storage <address> 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc --rpc-url "$ETH_RPC_URL"
```
If non-zero, this is a proxy. Report the implementation address and explore both.

### 3. Fetch Source (if verified)
```bash
cast source <address> --rpc-url "$ETH_RPC_URL"   # requires ETHERSCAN_API_KEY
cast interface <address> --rpc-url "$ETH_RPC_URL"
```
If source isn't available, generate the interface from bytecode and note it's unverified.

### 4. Read Key State
Based on the interface/source, call common view functions:
- `name()`, `symbol()`, `decimals()`, `totalSupply()` (if ERC-20/721)
- `owner()`, `admin()`, `paused()` (if governance/pausable)
- Any other notable public getters

### 5. Recent Activity
```bash
# Last few transactions to this contract
cast logs --from-block -1000 --address <address> --rpc-url "$ETH_RPC_URL" | head -50
```

### 6. Summary

Present a structured report:
- **Contract type**: ERC-20, ERC-721, custom, proxy, etc.
- **Key state**: balances, ownership, pause status
- **Proxy**: implementation address if applicable
- **Source**: verified or unverified, key functions
- **Recent activity**: notable events or patterns
