---
name: foundry-cast
version: 1.0.0
description: Read EVM state, transactions, logs, and calldata with Foundry cast. Use for on-chain data, transaction hashes, contract addresses, or calldata.
---

Use `cast` and consult the relevant subcommand's `--help`.
Foundry binaries live in `~/.foundry/bin`.
Installation or updates require approval.
Set `ETH_RPC_URL` from the network below.
Default to Sepolia unless mainnet is requested, except ENS resolution and reverse lookup always use mainnet.
Internal RPC endpoints require VPN.

| Network | Chain ID | RPC URL |
|---------|----------|---------|
| Sepolia | 11155111 | `https://rpc.eth-sepolia.blockchain.o1o01lllo1io.com` |
| Mainnet | 1 | `https://rpc.eth-mainnet.blockchain.o1o01lllo1io.com` |

Before `cast send` or `cast publish`, show the target, network, value, and decoded calldata and get explicit confirmation.
In cast v1.5.1, `logs` has no `--topic0`/`--topic1`/`--topic2`.
Use raw `eth_getLogs` for topic-position filtering, with JSON `null` wildcards and address topics left-zero-padded to 32 bytes.
Native ETH transfers emit no events.
Use balance or transaction data rather than logs.
`cast source` and `cast interface` need `ETHERSCAN_API_KEY` and verified contracts.
