// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";


contract MutualFund is VRFConsumerBase, Ownable {

	///////////////////////////
	// VARIABLES DECLARATION //
	///////////////////////////

	// custom data types
	enum FUND_STATE {
		READY,
		COMPUTING_JUREES // to prevent 2 calls at the same time
	}

	enum REQUEST_STATE {
		OPEN,
		ACCEPTED,
		REFUSED,
		ERROR
	}

	struct Request {
		REQUEST_STATE state; // index 0
		uint256 amount;// index 1
		address requester; //index 2
		address payable[5] jury_members; // index 3
		uint256 jury_members_array_size; // index 4
		// // mapping to see if juree has voted :
		mapping(address => bool) hasVoted; // default is false : OK
	}


	// contract itself
	FUND_STATE public fund_state;


	// users
	address payable[] public users;
	mapping(address => bool) public userIsPresent; // to quickly check if msg.sender is already a user
	mapping(address => uint256) public userBalance; // in WEI


	// requests
	Request[] public all_requests_array;
	mapping(uint256 => Request) public request_mapping; // to easily filter Requests per STATE
	uint256 public requests_number;

	// // VRF Settings
	uint256 public fee;
	bytes32 public keyHash;
	event RequestedRandomness(bytes32 requestId);
	uint256 public randomness;





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

		// VRF Settings
		fee = _fee;
		keyHash = _keyHash;

		// Set contract state
		fund_state = FUND_STATE.READY;

	}




	function enter() public payable {

		// prevent duplicates :
		require( userIsPresent[msg.sender] == false, "User is already present in the Fund");

		users.push(payable(msg.sender));
		userIsPresent[msg.sender] = true;
		userBalance[payable(msg.sender)] = msg.value;

	}

	function payMonthlyFee() public payable{
		userBalance[address(msg.sender)] = userBalance[address(msg.sender)] + msg.value;
	}


	function getTotalBalanceOfContract() public view returns(uint256){
		return address(this).balance;
	}


	///////////////
	// REQUESTS  //
	///////////////

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


	// function is public for test purposes only, should be private:
	function getJury_members() public returns(address payable[5] memory){
		// hardcoded array of 5 elements, to begin with :
		address payable[5] memory tmpArray = [users[2], users[4], users[5], users[7], users[8]];
		return tmpArray;
	}

	// submit a request
	function submitARequest(uint256 _amountRequested) public {

		require(
			fund_state == FUND_STATE.READY,
			"Contract is currently busy building a set of jury members, try later"
			);
		require(
			userIsPresent[msg.sender] == true,
			"User must enter the contract first"
			);

		Request memory newRequest;

		// create a random array of jury members.
		address payable[5] memory tmp_jury_members;
		tmp_jury_members = getJury_members();


		// fill in the tmp request and push it to the global array:
		newRequest.state = REQUEST_STATE.OPEN;
		newRequest.amount = _amountRequested;
		newRequest.requester = msg.sender;

		all_requests_array.push(newRequest);

		// get index of current request
		uint all_requests_array_last_index = all_requests_array.length - 1;

		// fill in the jury members array INSIDE the global array of request, couldn't make it work using
		// the tmp request here above.
		for(uint256 i = 0; i<5;i++){
			all_requests_array[all_requests_array_last_index].jury_members[i] = tmp_jury_members[i];
		}

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

  function getArrayOfJuryMembers(uint256 _index) public view returns(address payable[5] memory juryMembersArray){

  	Request memory tmp_request;
  	tmp_request = all_requests_array[_index];
		juryMembersArray = tmp_request.jury_members;

  	return juryMembersArray;
  }

	////////////////////
	// custom setters //
	////////////////////

	function setContractState(uint256 _newState) public onlyOwner {
		fund_state = FUND_STATE(_newState);
	}
}
