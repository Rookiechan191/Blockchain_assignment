# SepoliaVault

## Overview
SepoliaVault is a Solidity smart contract deployed on the Sepolia test network. It acts as a **vault** where externally owned accounts (EOAs) and contracts can safely deposit, store, and transfer Sepolia Ether (ETH).  

The contract ensures secure handling of funds by enforcing two rules:
1. **No account can send money from another account’s balance.**
2. **No account can send money if it does not have sufficient balance.**

This guarantees fairness and prevents unauthorized fund transfers.

---

## Features and Functions

### 1. Deposit Functions
- **`topUp()`**  
  Allows any EOA/contract to deposit ETH into the vault. The deposited amount is credited to the sender’s balance in the contract ledger.  

- **`receive()`**  
  The fallback deposit mechanism that automatically credits ETH sent directly to the contract address.  

**Usefulness:** Enables EOAs and contracts to store ETH securely.

---

### 2. Balance Tracking
- **`getBalance(address who)`**  
  Returns the ETH balance of a specific account inside the vault.  

- **`vaultBalance()`**  
  Returns the total ETH stored in the contract.  

**Usefulness:** Helps users check both individual and total vault balances.

---

### 3. Send Functions
- **`sendTo(address payable to, uint256 amount)`**  
  Sends ETH from the sender’s vault balance to another EOA/contract.  

- **`sendToWithPayload(address payable to, uint256 amount, bytes calldata payload)`**  
  Sends ETH along with a custom data payload. Useful for interacting with contracts.  

- **`directSend(address payable to)`**  
  Sends ETH directly from the sender (outside the vault ledger) to another EOA/contract.  

**Usefulness:** Supports all 4 transaction types:
1. **EOA → EOA** (e.g., Alice sends ETH to Bob)  
2. **EOA → Contract** (e.g., Alice funds a dApp)  
3. **Contract → EOA** (e.g., vault sends ETH back to Alice)  
4. **Contract → Contract** (e.g., vault interacts with another contract)  

---

### 4. Withdraw Function
- **`withdrawFunds(uint256 amount)`**  
  Allows a user to withdraw ETH from their vault balance to their EOA.  

**Usefulness:** Ensures users can safely recover their ETH.

---

### 5. Security Mechanism
- **`noReentry` modifier**  
  Protects all state-changing functions against **reentrancy attacks** by locking execution during transfers.  

**Usefulness:** Prevents recursive exploit attacks (e.g., DAO hack scenario).  

---

## Transaction Logic
- **Rule 1: Ownership Protection**  
  Ledger ensures only the sender’s balance is debited.  
- **Rule 2: Balance Validation**  
  Transactions fail if the sender does not have enough funds.  

---

## Example Workflow
1. **Alice (EOA) → Deposit**  
   Alice calls `topUp()` and deposits 2 ETH. Her vault balance becomes 2 ETH.  

2. **Alice (EOA) → Bob (EOA)**  
   Alice calls `sendTo(Bob, 1 ETH)`.  
   - Alice’s balance: 1 ETH  
   - Bob’s balance: 1 ETH  

3. **Alice (EOA) → Contract C**  
   Alice calls `sendToWithPayload(C, 0.5 ETH, payload)`.  
   - 0.5 ETH is transferred with data to Contract C.  

4. **Bob (EOA) → Withdraw**  
   Bob calls `withdrawFunds(1 ETH)` and gets 1 ETH in his wallet.  

---


## Justification for One Contract
Only one contract (`SepoliaVault`) is required because:
- It manages deposits, transfers, and withdrawals internally.  
- It securely enforces ownership and balance rules.  
- It handles all 4 transaction types (EOA ↔ EOA, EOA ↔ Contract, Contract ↔ EOA, Contract ↔ Contract).  

Thus, no additional contracts are needed.  

---
