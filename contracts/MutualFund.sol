// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";


contract MutualFund is VRFConsumerBase, Ownable {



	///////////////////////////
	// VARIABLES DECLARATION //
	///////////////////////////

	enum FUND_STATE {
		READY,
		COMPUTING_JUREES // to prevent 2 calls at the same time
	}

	FUND_STATE public fund_state;

	// to track the RNG behaviour :
	event RequestedRandomness(bytes32 requestId);

	address payable[] public users;
	mapping(address => uint256) public userBalance; // in WEI

	// random number written by chainlink VRF :
	uint256 public randomness;

	enum REQUEST_STATE {
		OPEN,
		ACCEPTED,
		REFUSED,
		ERROR
	}

	struct Request {
		REQUEST_STATE state; // index 0
		uint256 amount;// index 1
		// address payable[5] jury_members;
		// // mapping to see if juree has voted :
		// mapping(address => bool) hasVoted; // default is false : OK
	}

	Request[] public all_requests_array;
	// using a mapping to easily filter Requests per STATE :
	mapping(uint256 => Request) public request_mapping;
	uint256 public requests_number;
	Request public testRequest;

	// VRF Settings
	uint256 public fee;
	bytes32 public keyHash;


	///////////////
	// FUNCTIONS //
	///////////////


	// BASICS

	constructor(
		address _vrfCoordinator,
		address _link,
		uint256 _fee,
		bytes32 _keyHash
		) public VRFConsumerBase(_vrfCoordinator, _link){
		// owner = msg.sender;
		fee = _fee;
		keyHash = _keyHash;
		fund_state = FUND_STATE.READY;

		testRequest.state = REQUEST_STATE.OPEN;
		testRequest.amount = 6789;
	}




	function enter() public payable {

		// check if user is already in user's array AND balance is non zero :
	  // require(msg.value >= getEntranceFee(), "User already");

		// add user to user list:
		users.push(payable(msg.sender));
		// set his balance to
		userBalance[payable(msg.sender)] = msg.value;
	}

	function payMonthlyFee() public payable{
		userBalance[address(msg.sender)] = userBalance[address(msg.sender)] + msg.value;
	}


	function getTotalBalanceOfContract() public view returns(uint256){
		// use a global variable updated at each transaction? To avoid huge computation
		// at each call?
		return address(this).balance;
	}


	/////////////////////////
	// REQUESTS MANAGEMENT //
	/////////////////////////

	function getMaxRequestAmount(address _userAddress) private view returns(uint256){

		// returns max amount possible for a user it must be maximum equal to multiple*user_balance
		// AND maximum equal to than 1% of Contract balance

		uint256 maxAmount;
		uint256 maxAmountAccordingToUserBalance = userBalance[_userAddress]*10;
		uint256 maxAmountAccordingToContractBalance = (getTotalBalanceOfContract() * 1)/100;

		if(maxAmountAccordingToUserBalance > maxAmountAccordingToContractBalance){
			return maxAmountAccordingToContractBalance;
		}

		return maxAmountAccordingToUserBalance;

	}


	// funciton is public for test purposes only, should be private:
	function getJury_members() public returns(address payable[5] memory){
		// hardcoded array of 5 elements, to begin with :
		return [users[2], users[4], users[5], users[7], users[8]];
	}




	function submitARequest(uint256 _amountRequested) public {
		require(
			fund_state == FUND_STATE.READY,
			"Contract is currently busy creating a juree, try later"
			);
		// require(user is actually a user)


		// create a random array of jury members.
		address payable[5] memory jury_members;
		jury_members = getJury_members();

		// create a Request struct
		Request storage newRequest;

		newRequest.state = REQUEST_STATE.OPEN;
		// newRequest.jury_members = jury_members;
		// // the follwing should be checked before:
		newRequest.amount = _amountRequested;

		// // fill the values for votes, nobody has voted by default :
		// for(uint256 i=0; i < 5; i++){
		// 	newRequest.hasVoted[newRequest.jury_members[i]] = false;
		// }
		// // create the nft (ideally)
		// put it inside the requests array
		all_requests_array.push(newRequest);


	}



	// function called by chainlink VRF :
	function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
	internal
	override
	{

		require(_randomness > 0, "random-not-found");
		randomness = _randomness;


	}

	////////////////////
	// custom getters //
	////////////////////

	function getUserNumbers() public view returns(uint256 count) {
		return users.length;
	}
}
