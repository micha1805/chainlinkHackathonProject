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

  // Address of all users
  address payable[] public users;
	// balance of each user, defautl to 0 :
	mapping(address => uint256) public userBalance; // in WEI

	// random number written by chainlink VRF :
	uint256 public randomness;



	///////////////////////
	// REQUEST VARIABLES //
	///////////////////////

	enum REQUEST_STATE {
		OPEN,
		ACCEPTED,
		REFUSED,
		ERROR
	}


	// custom type to store request info :
	struct Request {
		REQUEST_STATE state;
		address payable[5] jury_members;
		// mapping to see if juree has voted :
		mapping(address => bool) hasVoted; // default is false : OK
	}

	// store all requests :
	Request[] public all_requests_array;
	// using a mapping to easily filter Requests per STATE :
	mapping(uint256 => Request) public request_mapping;
	uint256 public requests_number;

	// settings variables, modifiables by owner
	uint256 public max_multiple = 10;
	uint256 public jurees_number = 5;
	uint256 public max_percentage_per_request = 1;
	// for simplicity the juree's numbere is fixed :
	// uint256 public FIXED_JURY_MEMBERS_AMOUNT = 5;

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
		uint256 maxAmountAccordingToUserBalance = userBalance[_userAddress]*max_multiple;
		uint256 maxAmountAccordingToContractBalance = (getTotalBalanceOfContract() * max_percentage_per_request)/100;

		if(maxAmountAccordingToUserBalance > maxAmountAccordingToContractBalance){
			return maxAmountAccordingToContractBalance;
		}

		return maxAmountAccordingToUserBalance;

	}



	function getJury_members() private returns(address payable[5] memory){
		// hardcoded array of 5 elements, to begin with :
		return [users[2], users[4], users[5], users[7], users[8]];
	}




	function submitARequest() public {
		require(
			fund_state == FUND_STATE.READY,
			"Contract is currently busy creating a juree, try later"
			);


		// create a random array of jury members.
		address payable[5] memory jury_members;
		jury_members = getJury_members();

		// create a Request struct
		Request memory newRequest;

		newRequest.state = REQUEST_STATE.OPEN;
		newRequest.jury_members = jury_members;

		// create the nft (ideally)
		// put it inside the requests array
		all_requests_array.push(newRequest);


	}



	// function called bu chainlink VRF :
	function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
	internal
	override
	{

		require(_randomness > 0, "random-not-found");
		randomness = _randomness;


	}


	// function getRandomArrayOfJurees() private {

	// 	// This function gets ONE random number from Chainlink VRF, converts it to an index number, from
	// 	// then iterate to the N next adresses to get correct amount of accounts.
	// 	// This is not optimal (each different group of jurees will always be very similar), also if you
	// 	// create N accounts and enter the contract afterwards, you could easily get a huge lever in
	// 	// a juree if all of them are selected to be juree.
	// 	// This 'trick' is done mainly to reduce gas fee due to :
	// 	// 1) big computations (a random subarray needs a lot of permutation computations) and
	// 	// 2) multiple calls to Chainlik VRF to get multiple different indexes, we only us 1 call here.
	// 	//
	// 	// Next versions of this contract should get a better way to choose N different random users.


	// 	// before everything :  prevent another computation :
	// 	fund_state = FUND_STATE.COMPUTING_JUREES;

	// 	// FIRST STEP : Get a random number

	// 	bytes32 requestId = requestRandomness(keyHash, fee);
	// 	// emit to event to track it :
	// 	emit RequestedRandomness(requestId);


 //    // SECOND STEP : get a random array of users
 //    // delete jurees;



 //    // final step : reopenn the possibility to create a new juree.
 //    fund_state = FUND_STATE.READY;
 //  }


  function checkIfIAmAJuree() public{
  	// this function is called by the front to check if the user is in a new juree

  	// loop on all the open request, and check if my address is there.
  }

  function voteOfJureeForARequest(uint256 indexRequest, bool _vote) public {
  	// check if juree has already voted
  	// if not
  }

  function modifyRequestVote(uint256 indexRequest) private {

  }


  function getOpenRequestsIndexes() public view returns(uint[] memory filteredRequestsIndexes){

  	// uint256[] storage index_of_open_requests;
  	// Request[] memory requestsTemp = new Request[](requests_number);
  	// uint256 count;


  	// for(uint256 i=0;i<requests_number;i++){
  	// 	if(request_mapping[i].state == REQUEST_STATE.OPEN){
   //          requestsTemp[count] = request_mapping[i]; //or whatever you want to do if it matches
   //          count += 1;
   //    }
  	// }

  	// filteredRequestsIndexes = new uint256[](count);
  	// for(uint256 i = 0; i<count; i++){
   //    filteredRequestsIndexes[i] = requestsTemp[i].index;
   //  }

   //  // the following array contains the indexes of all the open requests :
  	return filteredRequestsIndexes;

  }


  function checkIfUserBelongsToAJureeOfACertainRequest(uint256 _userAddress, uint256 _requestIndex) public view returns(bool _answer){

  	_answer = false;

  	for(uint i=0;i<all_requests_array.length;i++){

	  	for(uint j=0;j<5;j++){
	  		if(address(all_requests_array[i].jury_members[i]) == msg.sender){
	  			_answer = true;
	  		}
	  	}

  	}

  	return _answer;
  }

	/////////////
	// SETTERS //
	/////////////

	function modifyJureesNumber(uint256 _newJureesNumber) public onlyOwner {
		jurees_number = _newJureesNumber;
	}

	function modifyMultiple(uint256 _newMultiple) public onlyOwner {
		max_multiple = _newMultiple;
	}

	// in case of bug, to avoid a broken contract:
	function forceSetting() public onlyOwner {
		fund_state = FUND_STATE.READY;
	}

	// // To be understood :
	// function checkEachMonth() private {} // Chainlink keeper CRON?
	//

}
