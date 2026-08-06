---
name: foundry-cast
version: 1.0.0
description: >-
  Foundry cast CLI for EVM chains: read state, decode calldata/logs, query txs/blocks, convert
  units, compute selectors. Trigger on on-chain data, tx hashes, contract addresses, or calldata.
---

# Foundry Cast

`cast` is Foundry's CLI for EVM chain interaction. Consult `cast --help` and `cast <subcommand>
--help` for the interface. This skill covers only what those cannot tell you.

## Install

If `cast --version` fails: run `foundryup` if `~/.foundry/bin/foundryup` exists, otherwise
`curl -L https://foundry.paradigm.xyz | bash` then `foundryup`. Binaries land in `~/.foundry/bin`.
Offer to persist that on PATH in the user's shell profile.

## RPC endpoints

| Network | Chain ID | RPC URL                                               |
|---------|----------|-------------------------------------------------------|
| Sepolia | 11155111 | `https://rpc.eth-sepolia.blockchain.o1o01lllo1io.com` |
| Mainnet | 1        | `https://rpc.eth-mainnet.blockchain.o1o01lllo1io.com` |

Export as `ETH_RPC_URL` so cast picks it up. **Default to Sepolia** unless the user says mainnet.
These are internal endpoints and need VPN; connection errors usually mean VPN is off.

ENS is the one exception to the Sepolia default: it lives on mainnet, so `cast resolve-name` and
`cast lookup-address` always need the mainnet URL.

## Safety

Read operations are safe to run freely. **Never run `cast send` or `cast publish` without explicit
user confirmation**: they submit real transactions and cost real ETH. Show the target, network,
value, and decoded calldata, then wait for an explicit yes.

## Gotchas

`cast logs` (v1.5.1) has no `--topic0`/`--topic1`/`--topic2` flags; passing them errors. To filter on
a non-first topic, use the raw RPC:

```bash
cast rpc eth_getLogs \
  '{"fromBlock":"0x0","toBlock":"latest","topics":["0xddf252ad...","null-or-value","0x<addr padded to 32 bytes>"]}' \
  --rpc-url "$ETH_RPC_URL"
```

`null` matches any value at that position, and address topics must be left-zero-padded to 32 bytes.
Native ETH transfers emit no events at all, so they are invisible to logs; use `cast balance`.

`cast source` and `cast interface` need `ETHERSCAN_API_KEY` and only work well on verified contracts.
