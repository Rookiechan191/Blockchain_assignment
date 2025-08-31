// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

contract SepoliaVault {
	mapping(address => uint256) private ledger;
	uint256 private _entered = 1;

	event DepositMade(address indexed sender, uint256 amount);
	event WithdrawalDone(address indexed recipient, uint256 amount);
	event FundsSent(address indexed from, address indexed to, uint256 amount);
	event FundsSentWithPayload(address indexed from, address indexed to, uint256 amount, bytes data);
	event DirectTransfer(address indexed from, address indexed to, uint256 amount);

	modifier noReentry() {
		require(_entered == 1, "Reentrancy");
		_entered = 2;
		_;
		_entered = 1;
	}

	function topUp() external payable {
		require(msg.value > 0);
		ledger[msg.sender] += msg.value;
		emit DepositMade(msg.sender, msg.value);
	}

	
	receive() external payable {
		require(msg.value > 0);
		ledger[msg.sender] += msg.value;
		emit DepositMade(msg.sender, msg.value);
	}

	
	function getBalance(address who) external view returns (uint256) {
		return ledger[who];
	}

	
	function sendTo(address payable to, uint256 amount) external noReentry {
		require(to != address(0));
		require(amount > 0);
		uint256 bal = ledger[msg.sender];
		require(bal >= amount, "Insufficient balance");
		unchecked { ledger[msg.sender] = bal - amount; }
		(bool ok, ) = to.call{value: amount}("");
		require(ok, "Send failed");
		emit FundsSent(msg.sender, to, amount);
	}

	
	function sendToWithPayload(address payable to, uint256 amount, bytes calldata payload) external noReentry {
		require(to != address(0));
		require(amount > 0);
		uint256 bal = ledger[msg.sender];
		require(bal >= amount, "Insufficient balance");
		unchecked { ledger[msg.sender] = bal - amount; }
		(bool ok, ) = to.call{value: amount}(payload);
		require(ok, "Send failed");
		emit FundsSentWithPayload(msg.sender, to, amount, payload);
	}

	
	function withdrawFunds(uint256 amount) external noReentry {
		require(amount > 0);
		uint256 bal = ledger[msg.sender];
		require(bal >= amount, "Insufficient balance");
		unchecked { ledger[msg.sender] = bal - amount; }
		(bool ok, ) = payable(msg.sender).call{value: amount}("");
		require(ok, "Withdraw failed");
		emit WithdrawalDone(msg.sender, amount);
	}

	
	function directSend(address payable to) external payable noReentry {
		require(to != address(0));
		require(msg.value > 0);
		(bool ok, ) = to.call{value: msg.value}("");
		require(ok, "Direct send failed");
		emit DirectTransfer(msg.sender, to, msg.value);
	}

	
	function vaultBalance() external view returns (uint256) {
		return address(this).balance;
	}
}