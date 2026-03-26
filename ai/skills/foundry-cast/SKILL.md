---
name: foundry-cast
version: 1.0.0
description: >-
  Foundry cast CLI for EVM chains: read state, decode calldata/logs, query txs/blocks, convert
  units, compute selectors. Trigger on on-chain data, tx hashes, contract addresses, or calldata.
---

# Foundry Cast

## Overview

`cast` is Foundry's Swiss Army knife for EVM chain interaction from the command line. Use it for all
on-chain queries — reading contract state, looking up transactions, decoding calldata, querying
events, ENS resolution, unit conversions, and more. It handles ABI encoding/decoding natively, so
you rarely need a separate ABI file for individual calls.

## Prerequisites

Before running any cast command, check that the Foundry toolchain is installed:

```bash
cast --version
```

If cast is not found, there are two possible states:

**foundryup is installed but cast is not** — The user ran the installer previously but never ran
`foundryup` to download the toolchain. Check for this first:

```bash
# Check if foundryup exists
[ -x "$HOME/.foundry/bin/foundryup" ] && echo "foundryup found" || echo "not installed"
```

If foundryup exists, just run it:

```bash
export PATH="$HOME/.foundry/bin:$PATH"
foundryup
```

**Neither foundryup nor cast is installed** — Full install from scratch:

```bash
# Download and run the foundryup installer
curl -L https://foundry.paradigm.xyz | bash

# Add ~/.foundry/bin to PATH for this session
export PATH="$HOME/.foundry/bin:$PATH"

# Install the latest toolchain (cast, forge, anvil, chisel)
foundryup
```

After installation, verify with `cast --version`.

**Persist PATH in the shell profile** — If `~/.foundry/bin` is not already in the user's shell
profile, offer to add it so cast is available in future sessions. Detect the shell and check the
appropriate profile:

```bash
# Determine the user's shell profile
case "$SHELL" in
  */zsh)  PROFILE="$HOME/.zshrc" ;;
  */bash) PROFILE="$HOME/.bashrc" ;;
  *)      PROFILE="$HOME/.profile" ;;
esac

# Check if already configured
grep -q '.foundry/bin' "$PROFILE" 2>/dev/null && echo "already configured" || echo "not configured"
```

If not configured, offer to append it:

```bash
echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$PROFILE"
```

To update an existing installation to the latest version, just run `foundryup` again.

## RPC Configuration

Cast needs an RPC endpoint for on-chain queries. Use these internal endpoints:

| Network | Chain ID | RPC URL                                               |
|---------|----------|-------------------------------------------------------|
| Sepolia | 11155111 | `https://rpc.eth-sepolia.blockchain.o1o01lllo1io.com` |
| Mainnet | 1        | `https://rpc.eth-mainnet.blockchain.o1o01lllo1io.com` |

Pass via `--rpc-url` or export as `ETH_RPC_URL` so cast picks it up automatically.
Default to **Sepolia** unless the user explicitly specifies mainnet:

```bash
export ETH_RPC_URL="https://rpc.eth-sepolia.blockchain.o1o01lllo1io.com"
```

## Safety

**Read operations are safe to run freely** — they don't modify chain state.

**Never run `cast send` or `cast publish` without explicit user confirmation.** These submit
transactions on-chain and cost real ETH. Always show the user what will be sent (to, value,
calldata) and get a clear "yes" before executing — review first, then act.

## Common Operations

### Chain Queries

```bash
cast block-number --rpc-url "$ETH_RPC_URL"
cast block latest --rpc-url "$ETH_RPC_URL"
cast chain-id --rpc-url "$ETH_RPC_URL"
cast gas-price --rpc-url "$ETH_RPC_URL"
cast base-fee --rpc-url "$ETH_RPC_URL"
cast balance <address> --rpc-url "$ETH_RPC_URL"
cast nonce <address> --rpc-url "$ETH_RPC_URL"
cast code <address> --rpc-url "$ETH_RPC_URL"
```

### Reading Contracts

```bash
# Call a view/pure function (no ABI needed if you know the signature)
cast call <address> "balanceOf(address)(uint256)" <holder> --rpc-url "$ETH_RPC_URL"
cast call <address> "totalSupply()(uint256)" --rpc-url "$ETH_RPC_URL"
cast call <address> "name()(string)" --rpc-url "$ETH_RPC_URL"

# Read raw storage slot
cast storage <address> <slot> --rpc-url "$ETH_RPC_URL"

# Compute storage slot for a mapping key
cast index address <key> <mapping_slot>
```

The function signature format is `"functionName(inputTypes)(outputTypes)"`. Cast handles the ABI
encoding internally — no separate ABI file is needed for individual calls.

### Transactions and Receipts

```bash
cast tx <tx_hash> --rpc-url "$ETH_RPC_URL"
cast receipt <tx_hash> --rpc-url "$ETH_RPC_URL"

# Trace a transaction locally (requires archive node or debug_traceTransaction)
cast run <tx_hash> --rpc-url "$ETH_RPC_URL"
```

### Decoding and Encoding

```bash
# Decode calldata using a known function signature
cast decode-calldata "transfer(address,uint256)" <calldata>

# Decode using 4byte directory (auto-lookup from openchain.xyz)
cast 4byte-calldata <calldata>

# Look up a function selector
cast 4byte <selector>          # e.g., cast 4byte 0xa9059cbb

# Decode event log data
cast decode-event "Transfer(address indexed,address indexed,uint256)" <topics_and_data>

# Look up event topic0
cast 4byte-event <topic0>

# ABI-encode function arguments (without selector)
cast abi-encode "transfer(address,uint256)" <to> <amount>

# ABI-encode with selector (full calldata)
cast calldata "transfer(address,uint256)" <to> <amount>

# Compute function selector
cast sig "transfer(address,uint256)"

# Keccak256 hash
cast keccak "some text"
```

### ENS

ENS resolution is an exception to the Sepolia default — ENS lives on mainnet, so always use
the mainnet RPC endpoint for these commands:

```bash
cast resolve-name vitalik.eth --rpc-url "https://rpc.eth-mainnet.blockchain.o1o01lllo1io.com"
cast lookup-address <address> --rpc-url "https://rpc.eth-mainnet.blockchain.o1o01lllo1io.com"
cast namehash vitalik.eth
```

### Unit Conversions

These are pure local computations — no RPC needed:

```bash
# Wei <-> Ether
cast to-wei 1.5 ether             # 1500000000000000000
cast from-wei 1500000000000000000 # 1.500000000000000000

# Wei <-> Gwei
cast to-wei 30 gwei               # 30000000000
cast from-wei 30000000000 gwei    # 30.000000000

# Hex <-> Decimal
cast to-hex 255                   # 0xff
cast to-dec 0xff                  # 255

# Format with custom decimals (e.g., USDC has 6 decimals)
cast format-units 1000000 6       # 1.000000
cast parse-units 1.0 6            # 1000000

# Other base conversions
cast to-base 255 16               # ff
cast to-base 0xff 10              # 255
```

### Address Utilities

```bash
cast to-check-sum-address <address>
cast compute-address --nonce <nonce> <deployer>
cast create2 --starts-with 0x00 --init-code-hash <hash> --deployer <addr>
```

### ERC-20 Token Shortcuts

```bash
cast erc20-token balance <token_address> <holder_address> --rpc-url "$ETH_RPC_URL"
```

### Querying Event Logs

```bash
cast logs --from-block 18000000 --to-block 18001000 \
  --address <contract> \
  "Transfer(address indexed,address indexed,uint256)" \
  --rpc-url "$ETH_RPC_URL"
```

### Wallet Operations

```bash
# Generate a new keypair
cast wallet new

# Get address from a private key
cast wallet address --private-key <key>

# Sign a message
cast wallet sign "message" --private-key <key>

# Verify a signature
cast wallet verify --address <addr> "message" <signature>
```

### JSON Output

Most cast commands support `--json` for machine-readable output:

```bash
cast block latest --json --rpc-url "$ETH_RPC_URL"
cast tx <hash> --json --rpc-url "$ETH_RPC_URL"
```

## Troubleshooting

- **"execution reverted"** — The contract call failed. Check the function signature, arguments,
  and that the target address is actually a contract. Use `cast code <address>` to verify.
- **Connection errors** — Verify the RPC URL is correct and the endpoint is reachable. Check VPN
  if using internal endpoints.
- **Empty response from `cast call`** — Likely a wrong function signature or the contract doesn't
  implement that function. Double-check input/output types.

## Tips

- Use `--json` when you need structured output for further processing
- For verified contracts, `cast source <address> --rpc-url "$ETH_RPC_URL"` fetches the source from
  Etherscan (requires ETHERSCAN_API_KEY)
- `cast estimate` gives gas estimates before sending:
  `cast estimate <to> "func(args)" --rpc-url "$ETH_RPC_URL"`
- `cast interface <address> --rpc-url "$ETH_RPC_URL"` generates a Solidity interface from on-chain
  bytecode (works best with verified contracts and ETHERSCAN_API_KEY)
