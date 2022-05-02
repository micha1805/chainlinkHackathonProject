// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MutualFund{



	///////////////////////////
	// VARIABLES DECLARATION //
	///////////////////////////

	// // Needed ?
	// enum MUTUAL_FUND_STATE {
	// 	OPEN,
	// 	CLOSED
	// }



	address public owner;
	address payable[] public users;
	address[] public requestsArray;
	uint256 public randomness;
	mapping(address => uint256) public userBalance; // in WEI
	uint256 MAX_MULTIPLIER = 10; // eventually modifiable by owner






	///////////////
	// FUNCTIONS //
	///////////////


	constructor(){
		owner = msg.sender;
	}

	function enter() public {
		users.push(payable(msg.sender));
	}


	function payMonthlyFee() public payable{
		userBalance[address(msg.sender)] = userBalance[address(msg.sender)] + msg.value;
		// address(this).balance = address(this).balance + msg.value;
	}

	function getMaxRequestAmount(address _userAddress) private view returns(uint256){
		return userBalance[_userAddress]*MAX_MULTIPLIER;
	}



	//  TODO :
	// use ownable of openzeppelin, check lottery code

	function getTotalBalanceOfContract() public view returns(uint256){
		// use a global variable updated at each transaction? To avoid huge computation
		// at each call?
		return address(this).balance;
	}

	function quit() public {}
	function makeARequest() public {}
	function submitARequest() public {}
	function getToalContributionOfUser() public {}
	function getRandomArrayOfJurees() private{
		// Get 1 number and increment ? => no
	}
	function createAnNFTRequest() private {}


	// // To understand :
	// function checkEachMonth() private {} // Chainlink keeper CRON?
	//

}
