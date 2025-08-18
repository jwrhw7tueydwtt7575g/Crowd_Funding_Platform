## Crowdfunding Platform on Aptos (Move)

### Overview
This project implements a simple end-to-end crowdfunding platform in Move on Aptos. It includes:
- Soulbound Tokens (SBTs) and a basic reputation system
- Campaign creation, donations, milestones, and escrow
- A minimal voting flow for milestone approvals
- A placeholder zero-knowledge (ZK) donation verifier

Modules are organized under the named address `crowdfund` (declared in `Move.toml`).

### Project Layout
```
Move.toml
sources/
  sbt.move          # Soulbound token + reputation storage
  reputation.move   # Thin wrapper to update reputation via SBT
  campaign.move     # Campaigns, donations, milestones, escrow
  voting.move       # Minimal milestone voting (map-based)
  zk_donation.move  # Placeholder ZK donation verification
tests/
  crowdfunding_tests.move  # 3 unit tests covering full flow & error cases
```

### Prerequisites
- Aptos CLI installed and on PATH
- Git (Aptos downloads the framework on first compile)

On Windows, run the commands in PowerShell as you normally do [[memory:6537722]].

### Build and Test
- Compile:
```powershell
aptos move compile
```

- Run all tests:
```powershell
aptos move test
```

If you want verbose test output, add `--verbose`.

### Addresses and Modules
`Move.toml` binds the named address:
```toml
[addresses]
crowdfund = '0x8347a3145bc7eed7b615ebf6afa7989b138ffa1eaf347913d64da44aa06f0a3b'
```

All modules are published under `crowdfund::` (e.g., `crowdfund::campaign`).

---

## Module Reference

### 1) `sources/sbt.move` — Soulbound Tokens and Reputation
Purpose: A minimal soulbound token (SBT) per address that also stores a simple reputation score.

- Types
  - `struct SBT has key`:
    - `reputation: u64`
    - `owner: address`
    - `collection_name: vector<u8>`
    - `name: vector<u8>`
    - `uri: vector<u8>`

- Errors
  - `E_ALREADY_HAS_SBT = 0`

- Public API
  - `entry fun mint_sbt(account: &signer, collection_name, name, uri, soul_bound_to)`
    - Creates and stores an `SBT` at `account` if none exists.
    - Aborts with `already_exists(E_ALREADY_HAS_SBT)` if an SBT already exists.
  - `fun has_sbt(addr): bool`
  - `fun get_reputation(addr): u64 acquires SBT`
  - `fun update_reputation_by_delta(addr, delta, add: bool) acquires SBT`
    - Adds or subtracts `delta` from `reputation`.

Notes:
- This module purposefully avoids the full token framework to keep things simple.

### 2) `sources/reputation.move` — Reputation Wrapper
Purpose: Provide a single function to update reputation through `sbt`.

- Public API
  - `entry fun update_reputation(_account: &signer, user: address, delta: u64, add: bool)`
    - Calls `sbt::update_reputation_by_delta(user, delta, add)`.

### 3) `sources/campaign.move` — Campaigns, Donations, Milestones, Escrow
Purpose: Core crowdfunding logic and accounting.

- Types
  - `struct Milestone has store`:
    - `description: vector<u8>`
    - `target_amount: u64`
    - `approved: bool`
    - `voting_in_progress: bool`
  - `struct Campaign has key`:
    - `creator: address`
    - `goal: u64`
    - `raised: u64`
    - `milestones: vector<Milestone>`
    - `donors: SimpleMap<address, u64>`
    - `escrow: coin::Coin<AptosCoin>`

- Errors
  - `E_CAMPAIGN_NOT_FOUND = 100` (reserved, not currently used)
  - `E_MILESTONE_NOT_MET = 101`
  - `E_INSUFFICIENT_FUNDS = 102`
  - `E_NOT_OWNER = 103`

- Entry Functions
  - `entry fun create_campaign(account, goal, milestone_descriptions, milestone_amounts)`
    - Stores a `Campaign` under `account` (the creator). Requires the creator to have an SBT.
  - `entry fun donate(account, campaign_addr, amount) acquires Campaign`
    - Transfers `AptosCoin` to `campaign_addr`, increments `raised`, updates donor map, merges funds into `escrow`, and updates donor reputation (+1) via `reputation::update_reputation`.
  - `entry fun claim_milestone(account, campaign_addr, milestone_index) acquires Campaign`
    - Only the creator can start the claim; marks the milestone as `voting_in_progress = true`.
  - `entry fun release_funds(campaign_addr, milestone_index) acquires Campaign`
    - Requires `approved = true` and sufficient `escrow`, then extracts and deposits funds to `creator`.

- Helpers
  - `fun get_campaign_creator(campaign_addr): address acquires Campaign`
  - `fun get_raised(campaign_addr): u64 acquires Campaign`
  - `fun is_donor(campaign_addr, addr): bool acquires Campaign`
  - `fun update_campaign_raised(campaign_addr, amount) acquires Campaign`
  - `fun set_milestone_approved(campaign_addr, milestone_index, approved) acquires Campaign`
  - `fun set_milestone_voting_in_progress(campaign_addr, milestone_index, in_progress) acquires Campaign`

Important Storage Detail:
- The `Campaign` resource is stored under the creator’s account address. When interacting (donate/claim/release), pass the creator’s address as `campaign_addr`.

### 4) `sources/voting.move` — Minimal Voting
Purpose: A simple, map-based voting placeholder used to mark milestones as approved/rejected.

- Errors
  - `E_NOT_DONOR = 200`
  - `E_ALREADY_VOTED = 201`
  - `E_VOTE_NOT_ENDED = 202` (reserved)

- Types
  - `struct Vote has key`:
    - `campaign_addr: address`
    - `milestone_index: u64`
    - `yes_votes: u64`
    - `no_votes: u64`
    - `voters: SimpleMap<address, bool>`

- Entry Functions
  - `entry fun vote(account, vote_addr, yes) acquires Vote`
    - Requires the voter to be a donor of the campaign and not to have voted before. Increments yes/no counters and records the voter.
  - `entry fun end_vote(vote_addr) acquires Vote`
    - If `yes_votes > no_votes`, marks the milestone as approved via `campaign::set_milestone_approved`.
    - Clears `voting_in_progress` via `campaign::set_milestone_voting_in_progress`.

Note:
- `start_vote` is a placeholder; a full flow would create and publish a `Vote` resource.

### 5) `sources/zk_donation.move` — Placeholder ZK Donations
Purpose: Illustrates a shape for Groth16-style verification without real crypto.

- Types
  - `struct VerifyingKey { alpha, beta, gamma, delta: vector<u8> }`
  - `struct Proof { a, b, c: vector<u8> }`

- Entry Functions
  - `entry fun private_donate(_account, campaign_addr, proof_a, proof_b, proof_c, public_inputs, vk_alpha, vk_beta, vk_gamma, vk_delta)`
    - Asserts a fake `verify_groth16(..)` returns true, then calls `campaign::update_campaign_raised(campaign_addr, public_inputs[0])`.

Security Note:
- `verify_groth16` is a stub returning `true`. Replace with real verification before production use.

---

## Tests (`tests/crowdfunding_tests.move`)
The suite contains 3 tests. Run with:
```powershell
aptos move test
```

### 1) `test_full_flow`
End-to-end happy path:
1. Setup test accounts and register `AptosCoin`.
2. Mint SBTs for creator and both donors (required for reputation updates).
3. Creator creates a campaign with 2 milestones.
4. Two donors donate (300 and 200); `raised` becomes 500; funds move into `escrow`.
5. Creator claims a milestone, setting `voting_in_progress = true`.
6. (Voting is placeholder; release is not attempted here.)

Asserts:
- SBTs exist for the relevant accounts.
- `campaign::get_raised(creator_addr) == 500`.

### 2) `test_sbt_already_exists`
Error-path test for double-minting an SBT:
1. Mint SBT for the creator.
2. Attempt to mint again for the same address.

Asserts:
- Test is annotated with `#[expected_failure(abort_code = 524288, location = crowdfund::sbt)]` to match the `already_exists` abort path used by `sbt::mint_sbt`.

### 3) `test_zk_donation`
ZK-donation flow (placeholder):
1. Mint SBT for creator.
2. Create a campaign with one milestone.
3. Call `zk_donation::private_donate(..)` with mocked proof and verifying key bytes.

Asserts:
- `campaign::get_raised(creator_addr) == 300` after the call.

---

## Common Pitfalls and Tips
- Always pass the creator’s address as `campaign_addr` when interacting with a campaign; the `Campaign` is stored under the creator’s account.
- Ensure donors have SBTs before donation if your logic updates reputation, or adjust reputation logic for your needs.
- The voting module is intentionally minimal; extend it with proper lifecycle and storage for production.
- The ZK verifier is a stub; never use as-is for real proofs.

## Next Steps (Suggestions)
- Replace the ZK stub with a real verifier (e.g., integrating on-chain-friendly proof verification primitives).
- Harden voting: create `Vote` resources, add start/end times, quorum/threshold rules, and clean-up logic.
- Extend SBT/reputation: richer actions, decay, or badges.
- Add view functions (read-only) and indexer integration for better UX.

## License
MIT or your preferred license.


