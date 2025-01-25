# 🏆 Winner project at EthIndia 2024 - Best Project in Starkware Track. 🏆
# AML Transaction Compliance AVS

## Overview

This repository demonstrates an **Actively Validated Service (AVS)** integrated with the EigenLayer ecosystem to identify and flag suspicious transactions based on Anti-Money Laundering (AML) rules. By leveraging Ethereum restaking via EigenLayer, this AVS provides robust cryptoeconomic security, ensuring that the validation of off-chain compliance checks is both trust-minimized and economically incentivized.

**Key Features:**
- **AML Rule-Based Validation:** Defines basic AML rules to flag high-risk transactions:
  1. **High Volume Detection:** Transactions above a certain USD threshold are flagged.
  2. **Sanctioned Address Check:** Transactions involving known blacklisted or sanctioned addresses are flagged.
  3. **High Frequency Alert:** Unusually frequent transactions from the same address within a short timeframe are flagged.

- **Robust Security via Restaking:** Harnesses the EigenLayer protocol to tap into Ethereum’s staked ETH security, ensuring that operators who validate tasks have economically at stake, discouraging malicious or incorrect validation.

- **Multi-Operator Consensus:** Requires multiple operators (e.g., 3 operators) to process and agree on AML checks. Only when a majority (2 out of 3) agree that a transaction is suspicious does the AVS finalize the flag.

- **On-Chain Transparency:** Every finalized decision (flagged or not) is recorded and auditable on-chain. This transparency allows DeFi protocols, regulators, and end-users to trust the compliance checks without relying on a single centralized entity.

## Why Build an AVS for AML Compliance?

**EigenLayer’s Shared Security Model:**  
Traditionally, building secure decentralized services required bootstrapping independent validator networks—expensive and time-consuming. EigenLayer introduces “restaking,” allowing existing Ethereum stakers to secure new services. By building your AML compliance checks as an AVS:
- **Instant Access to Security:** Leverage Ethereum’s robust staking base without reinventing the security wheel.
- **Decentralized & Trust-Minimized:** Rely on decentralized operators, reducing the risk of single points of failure or manipulation.
- **Rapid Innovation:** Focus on the unique logic of AML compliance, rather than the overhead of building and securing a new network.

**AML Compliance in DeFi:**
DeFi projects face increasing regulatory scrutiny and must ensure their protocols are not exploited for money laundering or other illicit activities. An AVS provides:
- **Real-Time Monitoring:** DeFi protocols can integrate this AVS to continuously monitor transactions, identify suspicious activities, and take appropriate measures (e.g., blocking addresses, applying enhanced due diligence).
- **Transparent & Auditable Reports:** On-chain events and data enable protocols, auditors, and regulators to verify compliance measures have been consistently applied.
- **Reduced Regulatory Risk:** Implementing AML checks demonstrates proactive compliance, improving trust with institutional investors, regulators, and end-users.

## How It Works

1. **Transaction Task Creation:**  
   A script (off-chain) simulates or fetches real transaction data, then calls the AVS contract to create a “transaction task.” The task includes details like `txHash`, `from`, `to`, `amountUSD`, and `timestamp`.

2. **Operator Validation:**  
   Multiple AVS operators listen for new tasks, retrieve transaction data, and apply AML rules off-chain. Each operator independently decides if the transaction should be flagged.

3. **On-Chain Responses:**  
   Operators post their decisions back to the contract. Once a quorum (e.g., 2 out of 3 operators) agrees, the AVS contract finalizes the decision and emits an event, such as `AMLTaskFinalized`. If flagged, the transaction is considered suspicious; if not, it’s recorded as clean.

4. **Results & Integration:**  
   - **Frontend Dashboard (Optional):** A React-based dashboard visualizes flagged and normal transactions, providing an intuitive interface for compliance officers, regulators, or protocol governance members.
   - **Protocol Actions:** DeFi protocols can subscribe to AVS events and automatically apply additional compliance steps (e.g., halting suspicious trades, alerting governance, or marking the address for review).

## Example Use Cases for DeFi Projects

- **Decentralized Exchanges (DEXs):**  
  Integrate the AVS to monitor large swaps or suspicious trading patterns. Flagged transactions can trigger additional user verification steps or block further trades from blacklisted addresses.

- **Lending & Borrowing Protocols:**  
  If a borrower’s address suddenly executes large, rapid-fire loans and repayments, the protocol can pause that user’s activity until further inspection.

- **Liquidity Pools & AMMs:**  
  The AVS can detect when unusually large liquidity additions/withdrawals occur from suspicious addresses, helping maintain the integrity of liquidity distribution and prevent potential laundering through pooling strategies.

## Deployment and Testing

1. **Local Devnet Setup:**  
   - Run a local `anvil` chain: `npm run start:anvil`.
   - Deploy EigenLayer core contracts: `npm run deploy:core`.
   - Deploy the AML AVS contracts: `npm run deploy:aml`.
   - (Optional) Update ABIs: `npm run extract:abis`.

2. **Operator and Task Generation:**
   - Start the operator application: `npm run start:operator`.
   - Create tasks (simulated transactions): Adapt `createNewTasks.ts` to generate AML tasks and run `npm run start:traffic` or a similar command.

3. **Frontend Integration:**
   - Connect your React-based UI to listen for `AMLTaskFinalized` events.
   - Display flagged transactions and other metrics in a dashboard.

## Future Improvements

- **Advanced AML Rules:** Incorporate more sophisticated rules and external data sources (e.g., chain analysis APIs) to enhance detection accuracy.
- **Integration with Real Data Feeds:** Fetch live transaction data from real DeFi protocols to continuously monitor for suspicious behavior.
- **Slashing & Rewards:** Implement staking and slashing logic to penalize operators who misreport and reward honest participants, further strengthening security guarantees.

## Conclusion

This AML Compliance AVS demonstrates how Actively Validated Services on EigenLayer can empower DeFi protocols with robust, trust-minimized compliance checks. By reusing Ethereum’s security, incorporating multiple operator consensus, and logging all decisions on-chain, DeFi protocols can meet regulatory expectations and foster greater trust among users and regulators, ultimately contributing to a safer, more resilient financial ecosystem.
