// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract StructWithArrays {

	address[6] public test_addresses = [
	0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7,
	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
	0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
	0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,
	0x617F2E2fD72FD9D5503197092aC168c91465E7f2
	];

	struct Request {
		uint256 amount;// index 0
		address requester; //index 1
	    address payable[5] jury_members; // index 2
        uint256 jury_members_array_size; // index 3
  }

    Request[] public all_requests_array;

    Request public test_request;

    constructor() public{
    	test_request.amount = 12;
    	test_request.requester = msg.sender;
    	test_request.jury_members[0] = payable(msg.sender);
    	test_request.jury_members_array_size = 1;

    	Request memory tmp_request;
    	tmp_request = test_request;

    	all_requests_array.push(tmp_request);

    }

    function addRequestToArray() public {
    	Request memory tmp_request2;

    	tmp_request2.amount = 12;
    	tmp_request2.requester = msg.sender;

    	tmp_request2.jury_members[0] = payable(msg.sender);

    	tmp_request2.jury_members_array_size = 1;

    	all_requests_array.push(tmp_request2);


    }

    function addAddressToRequest(uint256 _index) public {
    	uint256 count = all_requests_array[_index].jury_members_array_size;
    	all_requests_array[_index].jury_members[count] = payable(test_addresses[count]);
    	all_requests_array[_index].jury_members_array_size = count + 1;
    }

    function getArrayOfRequest() public view returns(address payable[5] memory){
    	return test_request.jury_members;
    }

  // getter of array inside the array of requests :
  function getArrayOfRequest(uint256 _arrayIndex) public view returns(address payable[5] memory){
  	return all_requests_array[_arrayIndex].jury_members;
  }

  function getPseudoRandomArray() public view returns(address[3] memory){
  	address[3] memory tmpArray = [test_addresses[2], test_addresses[3], test_addresses[5]];
  	return tmpArray;
  }
}
