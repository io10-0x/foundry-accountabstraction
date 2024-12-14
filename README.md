# Account Abstraction Project (Ethereum and zkSync implementation): README

## Overview

This repository contains the implementation of an Account Abstraction (AA) project on **zkSync**, showcasing the flexibility and security of smart contract wallets on a Layer-2 solution. The project demonstrates core concepts like user-operated smart contract wallets, meta-transactions, gas abstraction, and signature verification using **EIP-4337** on the **zkSync** network.

## Features

- **Smart Contract Wallets:** Users interact with Ethereum through programmable accounts using zkSync's L2 network.
- **Meta-Transactions:** Supports transactions without requiring users to hold ETH for gas by allowing third parties (bundlers) to pay for transaction fees.
- **Gas Abstraction:** External payers cover gas fees, making the experience smoother for users.
- **Signature Verification:** Implements cryptographic signatures to authorise actions securely.
- **zkSync Integration:** Utilizes zkSync's high-speed and low-cost transaction capabilities.

---

## Contracts

### 1. `SmartAccount.sol`

A smart contract wallet for user operations, enabling programmable logic and signature-based execution, integrated with zkSync.

#### Key Points

- **Inherits From:**
  - `IAccount` (Interface defining AA functionality)
  - Custom security modules.
- **Core Functionality:**
  - Execute user operations through verified signatures.
  - Delegate calls for interaction with other contracts.
  - Support for gas abstraction with external payers.
- **zkSync Integration:** Leverages zkSync's L2 network for cost-efficient and fast transactions.
- **Custom Errors:**
  - Prevent unauthorised execution.
  - Validate signature integrity and transaction rules.
- **Note on zkSync AA Support:**
  - Supports zkSync's unique approach to Account Abstraction.
  - Ensures users' operations are processed efficiently while avoiding traditional gas fees.

---

### 2. `EntryPoint.sol`

The entry point for the Account Abstraction system, responsible for batching and processing user operations, integrated with zkSync.

#### Key Points

- **Batch Processing:** Executes multiple user operations in a single transaction on zkSync's L2.
- **Gas Handling:** Bundlers pay gas fees on behalf of users, with reimbursement from the wallet.
- **Verification Process:**
  - Ensures operation validity.
  - Verifies user signatures and preconditions.
  - Leveraging zkSync's layer-2 scaling, operations are processed with minimal delay.
- **Security Features:**
  - Reentrancy protection.
  - Ensures bundlers are compensated accurately.

---

### 3. `Validator.sol`

A helper contract for signature validation and user authentication.

#### Key Points

- **Signature Verification:** Implements EIP-1271 for standardised smart contract signature checks.
- **Custom Logic:** Supports rules for multi-signature wallets, social recovery, or role-based access.

---

## Testing

### Unit Testing

- Comprehensive tests for:
  - Correct execution of user operations.
  - Signature validation for different schemes.
  - Gas calculation and reimbursement in the zkSync environment.
  - Ensuring meta-transactions are correctly processed without requiring ETH.

### Security Testing

- Focused on ensuring:
  - No unauthorised operations.
  - Safe handling of meta-transactions.
  - Robustness against reentrancy and replay attacks in zkSync.

---

## Usage

### Deployment on zkSync

1. Clone the repository and initialise a Foundry project:

   ```bash
   git clone <repository-url>
   cd account-abstraction-zksync
   Compile the smart contracts:
   ```

bash
Copy code
forge build
Deploy contracts to zkSync testnet or mainnet using zkSync deployment tools.

Running Tests
Run all tests using Foundry:

bash
Copy code
forge test

## Tools and Libraries

- **zkSync:** Layer-2 scaling solution for Ethereum.
- **Foundry:** For smart contract development and testing.
- **OpenZeppelin Contracts:** Provides base implementations for ERC standards and security utilities.
- **EIP-4337 Reference Implementation:** Basis for the Account Abstraction system.
- **Forge-Std:** Testing utilities for Solidity development.

## Known Issues and Enhancements

- **Gas Refund Delays on zkSync:** In scenarios with rapid gas price changes, bundlers may experience delayed refunds.
- **Meta-Transactions Complexity:** Handling meta-transactions requires bundlers to pay gas fees, which may add complexity in certain situations.

## Future Enhancements:

Explore integration with zk-rollups for enhanced scalability.
Introduce advanced features such as multi-signature wallets and social recovery mechanisms.
Enhance multi-chain compatibility, allowing seamless use of zkSync with other Layer-2 solutions.

## License

- **This project is licensed under the MIT License.**

### Notes Included:

- **zkSync Integration**: Added specific details about zkSync's Layer-2 network and its role in Account Abstraction, including how it helps with cost-efficient and fast transactions.
- **Meta-Transactions & Gas Abstraction**: Emphasized zkSync's ability to handle gas abstraction and bundlers paying for gas, which is a core feature for the Account Abstraction model on zkSync.
