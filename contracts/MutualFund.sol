// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MutualFund{
	address[] public users;
	address public admin;
	// the following balance is in Wei
	mapping(address => uint256) public userBalance;

	constructor(){
		admin = msg.sender;
	}

	function enter() public {
		users.push(msg.sender);
	}

	// function payMonthlyFee() public{
	// 	userBalance[msg.sender] = userBalance[msg.sender] + msg.value;
	// 	// address(this).balance = address(this).balance + msg.value;
	// }




	//  next steps

	function getTotalBalanceOfContract() public returns(uint256){
		// use a global variable updated at each transaction? To avoid huge computation
		// at each call?
		return address(this).balance;
	}

	function submitARequest() public {}

}
