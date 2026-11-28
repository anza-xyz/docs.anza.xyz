---
title: Durable Transaction Nonces in the Solana CLI
pagination_label: "Solana CLI: Durable Transaction Nonces"
sidebar_label: Durable Transaction Nonces
---

Durable transaction nonces are a mechanism for getting around the typical short
lifetime of a transaction's
[`recent_blockhash`](https://solana.com/docs/core/transactions#recent-blockhash).
They are implemented as a Solana Program, the mechanics of which can be read
about in the [proposal](../../implemented-proposals/durable-tx-nonces.md).

## Usage Examples

Full usage details for durable nonce CLI commands can be found by running
`solana <command> --help`.

### Nonce Authority

Authority over a nonce account can optionally be assigned to another account. In
doing so the new authority inherits full control over the nonce account from the
previous authority, including the account creator. This feature enables the
creation of more complex account ownership arrangements and derived account
addresses not associated with a keypair. The
`--nonce-authority <AUTHORITY_KEYPAIR>` argument is used to specify this account
and is supported by the following commands

- `create-nonce-account`
- `new-nonce`
- `withdraw-from-nonce-account`
- `authorize-nonce-account`

### Nonce Account Creation

The durable transaction nonce feature uses an account to store the next nonce
value. Durable nonce accounts must be
[rent-exempt](../../implemented-proposals/rent.md#two-tiered-rent-regime), so need
to carry the minimum balance to achieve this.

A nonce account is created by first generating a new keypair, then create the
account on chain

- Command

```bash
solana-keygen new -o nonce-keypair.json
solana create-nonce-account nonce-keypair.json 1
```

- Output

```text
Signature: 2j3hbhH1HjWkEZi1YKz2kKjHyWjUXHsy4Vxz1jd1ugf2z9ANNe2mz2PVWWprouUBddqnugmrQccBVpe2vFmAyEZj
```

> To keep the keypair entirely offline, use the
> [Paper Wallet](../wallets/paper.md) keypair generation
> [instructions](../wallets/paper.md#seed-phrase-generation) instead

> For full usage documentation, run `solana create-nonce-account --help`

### Querying the Stored Nonce Value

Creating a durable nonce transaction requires passing the stored nonce value as
the value to the `--blockhash` argument upon signing and submission. Obtain the
presently stored nonce value with

- Command

```bash
solana nonce nonce-keypair.json
```

- Output

```text
HB9mj7UwBn1TVtiENKe8kBJD7FGQcgTeEVc3P2jZ2CHX
```

> For full usage documentation, run `solana nonce --help`

### Advancing the Stored Nonce Value

While not typically needed outside a more useful transaction, the stored nonce
value can be advanced by

- Command

```bash
solana new-nonce nonce-keypair.json
```

- Output

```text
Signature: 5fbsxpCSN8rieby2BZ9zQL9j8wXBb2Qm5m77Dfv4si7hxRXXoqhrPpvXW7qk9ivtxEzAPgJhHTGcNBGWhCxgwRau
```

> For full usage documentation, run `solana new-nonce --help`

### Display Nonce Account

Inspect a nonce account in a more human friendly format with

- Command

```bash
solana nonce-account nonce-keypair.json
```

- Output

```text
Balance: 1 SOL
Minimum Balance Required: 0.00144768 SOL
Nonce blockhash: 6qAx6MPdfef4Ad4KQiZMb6HdhCSHGuW9kadkdpu9aMQH
Fee: 5000 lamports per signature
Authority: 5oDEeishqikhzF9r4uRQaWwjEgsSXi3NVMRpjQKSeoaU
```

> For full usage documentation, run `solana nonce-account --help`

### Withdraw Funds from a Nonce Account

Withdraw funds from a nonce account with

- Command

```bash
solana withdraw-from-nonce-account nonce-keypair.json ~/.config/solana/id.json 0.5
```

- Output

```text
Signature: 2gDwFsFs8wZTkRazTtJm8KhLTHeAkvRLwTp1aYgvsPgUFbPbwjPiVbowvKuQ1v2hidbZSa1nkDtdmiyMPH6HT33c
```

> Close a nonce account by withdrawing the full balance

> For full usage documentation, run `solana withdraw-from-nonce-account --help`

### Assign a New Authority to a Nonce Account

Reassign the authority of a nonce account after creation with

- Command

```bash
solana authorize-nonce-account nonce-keypair.json nonce-authority.json
```

- Output

```text
Signature: 54awfuXfYxgTyohXqc5CseNsidJ8LbSEHNT2QotjuMx7nTVBqtBm2coEKR1xr7o1rHedTCmeqWyCcV45Jy6dLGcc
```

> For full usage documentation, run `solana authorize-nonce-account --help`

## Other Commands Supporting Durable Nonces

To make use of durable nonces with other CLI subcommands, two arguments must be
supported.

- `--nonce`, specifies the account storing the nonce value
- `--nonce-authority`, specifies an optional [nonce authority](#nonce-authority)

They are supported by `transfer` and by the stake and vote subcommands that send
a transaction, for example

- `transfer`
- `delegate-stake`
- `deactivate-stake`

A subcommand supports durable nonces if `solana <command> --help` lists
`--nonce`.

### Example Pay Using Durable Nonce

Here we demonstrate Alice paying Bob 0.01 SOL using a durable nonce. The
procedure is the same for all subcommands supporting durable nonces

#### - Create accounts

First we need some accounts for Alice, Alice's nonce and Bob

```bash
$ solana-keygen new -o alice.json
$ solana-keygen new -o nonce.json
$ solana-keygen new -o bob.json
```

#### - Fund Alice's account

Alice will need some funds to create a nonce account and send to Bob. Airdrop
her some SOL

```bash
$ solana airdrop -k alice.json 1
Requesting airdrop of 1 SOL

Signature: 41m8tVkDcjH3WYRtTMqjddUSG9sm3u7vjDvgnuYgG3sDfbiFBHGE6QtGqu7Ewm82EvAGWwhXr5CrAeAifENEyPEB

1 SOL
```

#### - Create Alice's nonce account

Now Alice needs a nonce account. Create one

> Here, no separate [nonce authority](#nonce-authority) is employed, so
> `alice.json` has full authority over the nonce account

```bash
$ solana create-nonce-account -k alice.json nonce.json 0.1
Signature: jTkr44TVDc4EugjEKFtjv9LaKuZZ4D2xop7g3MVjgwjg3jgAXw7X6Bex32wqM7qoNFsKTo5j5yAV33secqiUoRX
```

#### - A failed first attempt to pay Bob

Alice attempts to pay Bob, but takes too long to sign. The specified blockhash
expires and the transaction fails

```bash
$ solana transfer -k alice.json --blockhash expiredDTaxfagttWjQweib42b6ZHADSx94Tw8gHx11 bob.json 0.01
Error: Hash has expired expiredDTaxfagttWjQweib42b6ZHADSx94Tw8gHx11
```

#### - Nonce to the rescue!

Alice retries the transaction, this time specifying her nonce account and the
blockhash stored there

> Remember, `alice.json` is the [nonce authority](#nonce-authority) in this
> example

> Bob's account holds no SOL yet, so `transfer` needs
> `--allow-unfunded-recipient`

```bash
$ solana nonce-account nonce.json
Balance: 0.1 SOL
Minimum Balance Required: 0.00144768 SOL
Nonce blockhash: 9L6KXcPs97j6TJfvZ75HMcLA56582HJqon4iQozP2RuR
Fee: 5000 lamports per signature
Authority: 3kJ1NScgqfhHamGsHfa4HfVv7VDVvXRUwi7WFVEttpsj
```

```bash
$ solana transfer -k alice.json --blockhash 9L6KXcPs97j6TJfvZ75HMcLA56582HJqon4iQozP2RuR --nonce nonce.json --allow-unfunded-recipient bob.json 0.01
Signature: 3huKk6Y5BEKPPp1wsPVS9awYZiT6k4SqLdnUm1D4YAYj9zjouzSSBNAfEJ3ZkNRDuwwPMMdehXedqSs2HGWpjAFy
```

#### - Success!

The transaction succeeds! Bob receives 0.01 SOL from Alice and Alice's stored
nonce advances to a new value

```bash
$ solana balance -k bob.json
0.01 SOL
```

```bash
$ solana nonce-account nonce.json
Balance: 0.1 SOL
Minimum Balance Required: 0.00144768 SOL
Nonce blockhash: CsDxqUmMopLxHQJuqHv4zfV1VB9zDNve2oJ77VvW4969
Fee: 5000 lamports per signature
Authority: 3kJ1NScgqfhHamGsHfa4HfVv7VDVvXRUwi7WFVEttpsj
```
