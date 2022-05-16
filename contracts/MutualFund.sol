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
		mapping(address => bool) user_is_a_jury_member; //index 4
		uint256 jury_members_array_size; // index 5
		// // mapping to see if juree has voted :
		mapping(address => bool) hasVoted; // default is false : OK // index 6
		uint256 voteTotal; // every jury member increment this for a yes vote // index 7
		uint256 voteCount; // when this goes to 5 everybody has voted // index 8
	}


	// contract itself
	FUND_STATE public fund_state;


	// users
	address payable[] public users;
	uint256[] shuffledUsersIndex;
	uint256 usersArraySize;
	uint256[5] tmpJuryMembers;
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
	uint256 public randomness = 134123425;





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

		// add the new index in the shuffled array :
		shuffledUsersIndex.push(usersArraySize);
		// increment size of users arrays
		usersArraySize++;

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
			all_requests_array[all_requests_array_last_index].user_is_a_jury_member[tmp_jury_members[i]] = true;
		}

	}


	// // check the status of request to see if everybody has voted
	// function checkRequestStatus(uint256 _requestIndex) public {


	// }

	// vote for a request
	function voteForARequest(uint _requestIndex, bool _vote) public{

		// request mu be open
		require(all_requests_array[_requestIndex].state == REQUEST_STATE.OPEN, "request is closed");

		// must be a jury member:
		require(checkIfUserIsAJuryMember(_requestIndex, msg.sender), "You must be a jury member for that request");
		// cannot vote twice:
		require(all_requests_array[_requestIndex].hasVoted[msg.sender] == false, "you have already voted");

		// record the vote has been made:
		all_requests_array[_requestIndex].hasVoted[msg.sender] = true;

		// increment the vote total result if needed:
		if(_vote){
			uint256 currentTotalVote = all_requests_array[_requestIndex].voteTotal;
			all_requests_array[_requestIndex].voteTotal = currentTotalVote + 1;
		}

		// increment the value tracking the number of votes already made :
		uint256 currentVoteCount = all_requests_array[_requestIndex].voteCount;
		all_requests_array[_requestIndex].voteCount = currentVoteCount + 1;


		// check if everybody has voted
		// checkRequestStatus(_requestIndex);
		if(all_requests_array[_requestIndex].voteCount == 5){
				// everybody has voted
				// check the result
				// send the money of needed
				if(all_requests_array[_requestIndex].voteTotal > 2){
					// first set the request state to ERROR, such that if the transfer
					// reverts afterwards in the transfer, the state is already correct;
					all_requests_array[_requestIndex].state = REQUEST_STATE.ERROR;
					// send the money
					address payable requesterAddress = payable(all_requests_array[_requestIndex].requester);
					uint256 amountToTransfer = all_requests_array[_requestIndex].amount;
					// Set the status to accepted
					// transfer money:
					requesterAddress.transfer(amountToTransfer);
					// if the above suceeds, then change the request to correct state :
					all_requests_array[_requestIndex].state = REQUEST_STATE.ACCEPTED;

				}else{
					// set status to REFUSED
					all_requests_array[_requestIndex].state = REQUEST_STATE.REFUSED;
				}
			}


	}

	// this should be privaten but it's not for testing purposes :
	function shuffleUsers() public returns(uint256[5] memory juryMembersIndexes){
		uint256 _sampleSize;
		_sampleSize = 5;

    for(uint256 i = 0; i < _sampleSize; i++) {
        uint256 n = i + uint256(keccak256(abi.encodePacked(randomness, i))) % (shuffledUsersIndex.length - i);
        uint256 temp = shuffledUsersIndex[n];
        shuffledUsersIndex[n] = shuffledUsersIndex[i];
        shuffledUsersIndex[i] = temp;
        juryMembersIndexes[i] = temp;
        tmpJuryMembers[i] = temp;

    }

    return juryMembersIndexes;
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

  function checkIfUserIsAJuryMember(uint256 _requestIndex, address _addresToCheck) public view returns(bool){
  	return all_requests_array[_requestIndex].user_is_a_jury_member[_addresToCheck];
  }

  function checkIfJuryMemberHasVoted(uint256 _requestIndex, address _juryMember) public view returns(bool){
  	return all_requests_array[_requestIndex].hasVoted[_juryMember];
  }

  function getVoteCountOfRequest(uint256 _requestIndex) public view returns(uint256){
  	return all_requests_array[_requestIndex].voteCount;
  }

  function getVoteTotalOfRequest(uint256 _requestIndex) public view returns(uint256){
  	return all_requests_array[_requestIndex].voteTotal;
  }

  function getRequestStateAsNumber(uint256 _requestIndex) public view returns(uint256){

  	return uint256(all_requests_array[_requestIndex].state);
  }

  function getShuffledArrayOfUsers() public view returns(uint256[] memory ){
  	return shuffledUsersIndex;
  }

  function getArrayOfJuryMembersIndexes() public view returns(uint256[5] memory ){
  	return tmpJuryMembers;
  }

	////////////////////
	// custom setters //
	////////////////////

	function setContractState(uint256 _newState) public onlyOwner {
		fund_state = FUND_STATE(_newState);
	}
}
