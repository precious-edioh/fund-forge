# FundForge: Blockchain-Based Crowdfunding Platform

## Overview

FundForge is a decentralized crowdfunding protocol built on Stacks and secured by Bitcoin. It empowers creators and backers to connect directly, eliminating intermediaries and ensuring transparency, security, and accountability through smart contract automation.

## Core Features

- Zero-trust funding with automatic escrow
- Community-driven project validation via weighted voting
- Instant refunds for failed campaigns
- Milestone-based fund releases for creator alignment
- Transparent, minimal platform fees
- Flexible campaign customization

## System Architecture

FundForge is implemented as a Clarity smart contract with robust state management, error handling, and gas-optimized operations. The contract manages all campaign logic, contributions, voting, and fund flows on-chain.

### Key Components

- **Campaign Registry:** Stores campaign metadata, funding goals, status, and voting configuration.
- **Contribution Tracking:** Records each backer's investment, refund status, and voting power.
- **Governance Voting:** Enables contributors to vote on campaign outcomes, with votes weighted by contribution.
- **Campaign Directory:** Maintains a list of contributors per campaign for efficient stakeholder management.
- **Administrative Controls:** Platform owner can update fee rates and pause campaigns in emergencies.

## Contract Data Structures

- `campaigns`: Map of campaign details (creator, title, goal, status, etc.)
- `contributions`: Map of contributor investments and voting power
- `contributor-votes`: Map of votes per campaign and contributor
- `campaign-contributors`: List of all contributors for each campaign

## Key Functions

- `create-campaign`: Launch a new campaign with custom parameters
- `contribute`: Invest in a campaign and gain voting power
- `claim-funds`: Creator claims funds after successful campaign
- `request-refund`: Contributors claim refunds if campaign fails
- `vote`: Contributors vote on campaign outcome
- `cancel-campaign`: Creator cancels an active campaign
- `set-platform-fee-rate`: Admin updates platform fee
- `emergency-pause-campaign`: Admin pauses a campaign in emergencies

## Contract Flow Summary

1. **Campaign Creation:** Creator sets up campaign with funding goal, duration, and voting options.
2. **Contribution:** Backers contribute STX, tracked in escrow and mapped to voting power.
3. **Campaign End:** On deadline, contract checks if goal is met:
   - If successful: Creator can claim funds (minus platform fee), subject to governance vote if enabled.
   - If failed: Contributors can claim instant refunds.
4. **Governance:** Contributors vote on campaign outcome if voting is enabled; votes are weighted by contribution.
5. **Admin Controls:** Platform owner can update fees or pause campaigns for security.

## Security & Best Practices

- All state changes and fund flows are managed on-chain for full transparency.
- Comprehensive input validation and error handling prevent misuse.
- Platform fees are capped and adjustable only by the contract owner.

---

For detailed contract logic, see `contracts/fund-forge.clar`.
