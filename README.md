# CodeAlpha_PortfolioLockContract
# 🔒 PortfolioLock — Crypto Time-Lock Smart Contract

> A Solidity smart contract that lets users deposit **ETH or ERC20 tokens** with a custom lock-in period. Funds stay locked until the timer runs out — no early withdrawals, no exceptions. Built and tested on **Remix IDE**.

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-363636?logo=solidity)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Tested%20on%20Remix-brightgreen)

---

## 📌 Project Overview

This is **Task 4** of my CodeAlpha internship — a personal portfolio-style crypto locking contract. The idea: users deposit funds and set how long those funds should stay locked. The contract enforces the lock using `block.timestamp`, and withdrawals are blocked until the unlock time has actually passed.

Think of it like a personal savings vault on the blockchain — once you lock it, you (or anyone else) genuinely cannot touch it early.

---

## ✨ Features

| Feature | Description |
|---|---|
| 💰 ETH Deposits | Lock native ETH with a custom duration |
| 🪙 Token Deposits | Lock any ERC20 token (requires `approve()` first) |
| ⏳ Time Enforcement | Uses `block.timestamp` to block early withdrawals |
| 📦 Multiple Deposits | Each user can hold multiple separate locked deposits |
| 🔎 View Functions | Check all your deposits and time remaining until unlock |
| 🛡️ Safety | Uses OpenZeppelin's `SafeERC20` for secure token transfers |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| [Solidity](https://soliditylang.org/) `^0.8.20` | Smart contract language |
| [Remix IDE](https://remix.ethereum.org/) | Writing, compiling, deploying, and testing |
| [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts) | Secure, audited `IERC20` + `SafeERC20` implementation |
| Remix VM (Cancun) | Local test blockchain — no real ETH needed |

---

## 📂 Contract Structure

```
PortfolioLock.sol
├── struct Deposit          // token, amount, unlockTime, withdrawn flag
├── mapping deposits        // address => Deposit[]
├── depositETH()            // lock native ETH
├── depositToken()          // lock ERC20 tokens
├── withdraw()              // withdraw a specific deposit after unlock
├── getDeposits()           // view all deposits for a user
└── timeUntilUnlock()       // check time remaining on a deposit
```

---

## 🔑 Core Functions

| Function | Access | Description |
|---|---|---|
| `depositETH(uint256 lockDuration)` | `external payable` | Deposit ETH sent with the transaction; locks it for `lockDuration` seconds from now |
| `depositToken(address token, uint256 amount, uint256 lockDuration)` | `external` | Transfers `amount` of `token` from the user (needs prior `approve()`) and locks it |
| `withdraw(uint256 depositId)` | `external` | Withdraws a specific deposit **only if** `block.timestamp >= unlockTime` |
| `getDeposits(address user)` | `external view` | Returns the full list of deposits for a user |
| `timeUntilUnlock(address user, uint256 depositId)` | `external view` | Returns seconds remaining until that deposit unlocks (`0` if already unlocked) |

---

## ⏱️ How the Time-Lock Works

1. When a user deposits, the contract calculates:
   ```solidity
   unlockTime = block.timestamp + lockDuration
   ```
2. This `unlockTime` is stored per-deposit in the `deposits` mapping.
3. On `withdraw()`, the contract checks:
   ```solidity
   require(block.timestamp >= d.unlockTime, "Funds are still locked");
   ```
4. If the check fails, the transaction **reverts** — funds simply cannot move before the deadline.

---

## 🚀 Deploying & Testing on Remix

| Step | Action |
|---|---|
| 1 | Open [remix.ethereum.org](https://remix.ethereum.org/), create `PortfolioLock.sol`, paste the contract code |
| 2 | Go to **Solidity Compiler** tab → select `0.8.20+` → click **Compile** |
| 3 | Go to **Deploy & Run Transactions** tab → set Environment to **Remix VM (Cancun)** → click **Deploy** |
| 4 | Under **Deployed Contracts**, call `depositETH` — enter a lock duration (e.g. `60` seconds) and set the **Value** field (e.g. `0.1` ether) |
| 5 | Immediately call `withdraw(0)` → ❌ transaction **reverts** with `"Funds are still locked"` |
| 6 | Use Remix's console to increase blockchain time (`evm_increaseTime`) or wait it out on a testnet |
| 7 | Call `withdraw(0)` again → ✅ succeeds, ETH is transferred back |

> ⚠️ **Note:** On Remix's JS VM, `block.timestamp` only moves forward when a new transaction is mined — simply waiting in real time does nothing. You need to advance time via the console or send another tx.

---

## ✅ Test Results

| Test Case | Expected Result | Outcome |
|---|---|---|
| Withdraw before unlock time | Reverts with `"Funds are still locked"` | ✅ Passed |
| Withdraw after unlock time | Transfers funds successfully | ✅ Passed |
| Withdraw same deposit twice | Reverts with `"Already withdrawn"` | ✅ Passed |
| Deposit with 0 ETH | Reverts with `"No ETH sent"` | ✅ Passed |

---

## 📚 References

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Remix IDE Documentation](https://remix-ide.readthedocs.io/)
- [OpenZeppelin Contracts — IERC20 & SafeERC20](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20)
- [Ethereum `block.timestamp` docs](https://docs.soliditylang.org/en/latest/units-and-global-variables.html#block-and-transaction-properties)

---

## 🎓 About This Project

This project is part of my **CodeAlpha Blockchain Development Internship**, focused on building practical, testable smart contracts from scratch and understanding core Solidity concepts like mappings, time-based logic, and secure token handling.

---

## 📄 License

This project is licensed under the **MIT License**.
