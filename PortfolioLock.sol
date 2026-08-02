// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Personal Portfolio Lock Contract
/// @notice Deposit ETH or ERC20 tokens with a time-lock; withdraw only after unlock time
contract PortfolioLock {
    using SafeERC20 for IERC20;

    struct Deposit {
        address token;      // address(0) = ETH
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    // user => list of deposits
    mapping(address => Deposit[]) public deposits;

    event Deposited(address indexed user, uint256 indexed depositId, address token, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 indexed depositId, address token, uint256 amount);

    /// @notice Deposit ETH with a lock duration
    /// @param lockDuration seconds from now until funds unlock
    function depositETH(uint256 lockDuration) external payable {
        require(msg.value > 0, "No ETH sent");
        require(lockDuration > 0, "Lock duration must be > 0");

        uint256 unlockTime = block.timestamp + lockDuration;
        deposits[msg.sender].push(Deposit({
            token: address(0),
            amount: msg.value,
            unlockTime: unlockTime,
            withdrawn: false
        }));

        emit Deposited(msg.sender, deposits[msg.sender].length - 1, address(0), msg.value, unlockTime);
    }

    /// @notice Deposit ERC20 tokens with a lock duration (requires prior approve())
    function depositToken(address token, uint256 amount, uint256 lockDuration) external {
        require(token != address(0), "Invalid token");
        require(amount > 0, "Amount must be > 0");
        require(lockDuration > 0, "Lock duration must be > 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        uint256 unlockTime = block.timestamp + lockDuration;
        deposits[msg.sender].push(Deposit({
            token: token,
            amount: amount,
            unlockTime: unlockTime,
            withdrawn: false
        }));

        emit Deposited(msg.sender, deposits[msg.sender].length - 1, token, amount, unlockTime);
    }

    /// @notice Withdraw a specific deposit once its lock time has passed
    function withdraw(uint256 depositId) external {
        require(depositId < deposits[msg.sender].length, "Invalid deposit id");
        Deposit storage d = deposits[msg.sender][depositId];

        require(!d.withdrawn, "Already withdrawn");
        require(block.timestamp >= d.unlockTime, "Funds are still locked");

        d.withdrawn = true;
        uint256 amount = d.amount;

        if (d.token == address(0)) {
            (bool sent, ) = payable(msg.sender).call{value: amount}("");
            require(sent, "ETH transfer failed");
        } else {
            IERC20(d.token).safeTransfer(msg.sender, amount);
        }

        emit Withdrawn(msg.sender, depositId, d.token, amount);
    }

    /// @notice View all deposits for a user
    function getDeposits(address user) external view returns (Deposit[] memory) {
        return deposits[user];
    }

    /// @notice Time remaining until a deposit unlocks (0 if already unlocked)
    function timeUntilUnlock(address user, uint256 depositId) external view returns (uint256) {
        Deposit memory d = deposits[user][depositId];
        if (block.timestamp >= d.unlockTime) return 0;
        return d.unlockTime - block.timestamp;
    }
}
