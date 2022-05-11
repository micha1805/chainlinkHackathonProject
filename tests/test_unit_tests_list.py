from brownie import accounts, network, MutualFund, exceptions
import pytest
from scripts.helpful_scripts import (
	LOCAL_BLOCKCHAIN_ENVIRONMENTS,
	get_account,
	get_contract,
	deploy_mutual_fund
	)

# ## list of tests todo


# IMPORTANT : to get a struct value, you need to pass the index of the value to get it!!!!


# ## BACK

# contract ca be deployed
def test_contract_can_be_deployed():
	indexAccount = 0
	account = get_account(indexAccount)
	mutual_fund = deploy_mutual_fund(index=indexAccount)

	assert(mutual_fund)

# contract has and admin (ideally no but it's for the hackathon purpose, to keep a grip on the deployed contract if necessary)
def test_contract_has_an_owner():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
		pytest.skip("Only for local environnment testing")

	indexAccount = 0
	owner = get_account(indexAccount)
	mutual_fund = deploy_mutual_fund(index=indexAccount)

	account = mutual_fund.owner()

	assert( account == owner)

# a user can enter contract
def test_a_user_can_enter_contract():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
	   pytest.skip("Only for local environnment testing")

	# create contract and owner
	indexAccount = 0
	owner = get_account(indexAccount)
	mutual_fund = deploy_mutual_fund(index=indexAccount)

	# create a random user
	random_user = get_account(2)
	random_user2 = get_account(3)


	# attempt to enter the contract :
	mutual_fund.enter({"from": random_user})

	# get user frome the array :
	assert( mutual_fund.users(0) == random_user)
	assert(mutual_fund.userIsPresent(random_user) == True)
	assert(mutual_fund.userIsPresent(random_user2) == False)

def test_a_user_cannot_enter_twice():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
	   pytest.skip("Only for local environnment testing")

	# create contract and owner
	indexAccount = 0
	owner = get_account(indexAccount)
	mutual_fund = deploy_mutual_fund(index=indexAccount)

	# create a random user
	random_user = get_account(2)

	# attempt to enter the contract :
	mutual_fund.enter({"from": random_user})

	with pytest.raises(exceptions.VirtualMachineError):
		mutual_fund.enter({"from": random_user})



def test_a_user_not_belonging_to_the_contract_cannot_submit_a_request():

	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
	   pytest.skip("Only for local environnment testing")

	# create contract and owner
	indexAccount = 0
	owner = get_account(indexAccount)
	mutual_fund = deploy_mutual_fund(index=indexAccount)

	# create a random user
	random_user = get_account(2)

	with pytest.raises(exceptions.VirtualMachineError):
		mutual_fund.submitARequest(1234, {"from": random_user})




# a user can pay and enter the contract
def test_a_user_can_pay_while_entering_contract():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
		pytest.skip("Only for local environnment testing")

	TICKET_VALUE = 10000000000 #random value
	# create contract and owner
	indexAccount = 0
	owner = get_account(indexAccount)
	mutual_fund = deploy_mutual_fund(index=indexAccount)

	# create random users
	random_user1 = get_account(2)
	random_user2 = get_account(3)

	# attempt to enter the contract :
	mutual_fund.enter({"from": random_user1, "value": TICKET_VALUE})
	mutual_fund.enter({"from": random_user2, "value": TICKET_VALUE})


	# get user from the array :
	assert( mutual_fund.users(0) == random_user1)
	assert( mutual_fund.users(1) == random_user2)
	assert( mutual_fund.balance() == TICKET_VALUE*2)


# test deploy script
def test_can_deploy_contract():
	mutual_fund = deploy_mutual_fund()

	assert(mutual_fund)

def test_can_get_a_random_array_of_jury_members():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
		pytest.skip()
	number_of_users = 9
	mutual_fund = deploy_mutual_fund(totalUsers=number_of_users+1)

	# jury_numbers = mutual_fund.getJury_members({"from": new_account})

	assert(mutual_fund.getUserNumbers() == number_of_users)
	# assert(len(jury_numbers) == 5)


def test_user_cannot_submit_a_request_if_contract_is_busy():

	owner = get_account()
	mutual_fund = deploy_mutual_fund()
	amount_requested = 123456789101

	# set contract state to busy :
	mutual_fund.setContractState(1, {"from": owner})

	with pytest.raises(exceptions.VirtualMachineError):
		mutual_fund.submitARequest(amount_requested, {"from": owner})


def test_user_can_submit_a_request():

	owner = get_account()
	user = get_account(1)
	number_of_users = 9
	mutual_fund = deploy_mutual_fund(totalUsers=number_of_users+1)

	request_state =  {
		0: "OPEN",
		1: "ACCEPTED",
		2: "REFUSED",
		3: "ERROR"
	}

	amount_requested = 123456789101
	mutual_fund.submitARequest(amount_requested, {"from": user})
	print(f"First request\n State : {request_state[mutual_fund.all_requests_array(0)[0]]}\n Amount : {mutual_fund.all_requests_array(0)[1]}\n Requester : {mutual_fund.all_requests_array(0)[2]}")

	# test if the array contains something :
	assert(mutual_fund.all_requests_array(0) != None)

	# test if request is open : index 0 is 0
	assert(mutual_fund.all_requests_array(0)[0] == 0)

	# test if request amount is correct: index 1 is the amount requested
	assert(mutual_fund.all_requests_array(0)[1] == amount_requested)

	# test if requester is recorded in the request
	assert(mutual_fund.all_requests_array(0)[2] == user.address)

def test_an_array_of_jury_members_is_created_inside_the_request():

	######################################
	# IMPORTANT : HARDCODED JURY TEST !! #
	######################################

	user = get_account(1)
	number_of_users = 9
	mutual_fund = deploy_mutual_fund(totalUsers=number_of_users+1)

	amount_requested = 123456789101
	mutual_fund.submitARequest(amount_requested, {"from": user})


	last_request = mutual_fund.all_requests_array(0)
	last_request_jury_members_array = mutual_fund.getArrayOfJuryMembers(0)



	# for now it is hardcoded that the jury is made of the following users :
	# [users[2], users[4], users[5], users[7], users[8]]
	# everything is translated because the first one is the owner :

	jury_member1 = get_account(2 + 1).address
	jury_member2 = get_account(4 + 1).address
	jury_member3 = get_account(5 + 1).address
	jury_member4 = get_account(7 + 1).address
	jury_member5 = get_account(8 + 1).address

	jury_members_list = [jury_member1, jury_member2, jury_member3, jury_member4, jury_member5]

	print(f"last_request : {last_request}")
	print(f"last_request_jury_members_array : {last_request_jury_members_array}")
	print(f"Jury members from brownie accounts : {jury_members_list}")
	# check the whole array :
	assert(last_request_jury_members_array == jury_members_list)


	# check an individual address
	contract_check_value1 = mutual_fund.checkIfUserIsAJuryMember(0, jury_member5, {"from": user})

	non_jury_member = get_account(0).address
	contract_check_value2 = mutual_fund.checkIfUserIsAJuryMember(0, non_jury_member, {"from": user})

	# first user should be a jury member:
	assert(contract_check_value1)
	# second one not:
	assert(contract_check_value2 == False)


def test_owner_can_set_contract_state():
	owner = get_account()
	mutual_fund = deploy_mutual_fund()

	mutual_fund.setContractState(1, {"from": owner})
	assert(mutual_fund.fund_state() == 1)



# def test_a_jury_member_can_vote():
# 	owner = get_account()
# 	number_of_users = 9

# 	mutual_fund = deploy_mutual_fund(totalUsers=number_of_users+1)

# 	mutual_fund.submitARequest(amount_requested, {"from": owner})

	# for now it is hardcoded that the jury is the following users :
	# [users[2], users[4], users[5], users[7], users[8]]





def test_check_request():
	pass

def test_contract_can_compute_max_amount_per_request():
	pass














# # a user can quit contract
# def test_a_user_can_quit_contract():
# 	pass
# # a user can pay a monthly fee
# def test_a_user_can_pay_monthly_fee():
# 	pass
# # a user is kicked if he doesn't pay (use of chailink keeper cron)
# def test_banning_a_user_after_no_payment():
# 	pass
# # mock of chainink keeper ?
# # can make a request
# def test_a_user_can_make_a_request():
# 	pass
# # the request is an nft
# def test_the_request_is_a_NFT():
# 	pass
# # the nft contains the correct fields
# def test_the_request_nft_has_the_correct_fields():
# 	pass
# # can select 100 random users if nb users > 100
# def test_the_contract_can_select_100_random_users_if_nb_user_is_greater_than_100():
# 	pass
# # can select 100 random users if nb users < 100
# def test_the_contract_cannnot_select_100_random_users_if_nb_user_is_smaller_than_100():
# 	pass
# # if the juree does not answer i due time he is kicked of the contract
# def test_juree_is_kicked_out_if_he_does_not_answer_in_due_time():
# 	pass
# # if > 50% of the jurees agree to the request the money is sent
# def test_therequest_is_accepted_to_the_majority():
# 	pass
# # the money is actually sent to the requester, and the amount is correct
# def test_the_money_is_correctly_received():
# 	pass
# # the full history of requests is publicly available, just an array of all the nfts created
# def test_full_history_of_requests_is_public():
# 	pass


# # ## BACK v2 :
# # the juree can modify the amount requested ?
# # the amount requested MUST be this : min(1% of total fund, 10x the total paid by the requester)
# # the admin can change some parameters (% of total fund per request, multiplier of requestant according to how much he has paid in total)
# # if a user quits or is being kicked out, he CANNOT gets his funds back and needs to go back fro beginning (it is important because the amout requestable is proportional to the total contribution of the user)
# # a user can be kicked if he has lied : a new nft is created with the information of the fake request (actually the nft created), a new request is sent to 100 people and the judge if the request was actually a lie and the user must be kicked.





# # ## FRONT
# # the front can make the user enter AND quit the contract
# def test_front_can_make_the_user_enter_and_quit_the_contract():
# 	pass
# # the front can access the contract
# def test_front_can_access_the_contract():
# 	pass
# # the front can check if the user has become a juree
# def test_front_can_check_if_user_has_become_a_juree():
# 	pass
# # the front can read the nft and its content
# def test_front_can_read_the_nft_request():
# 	pass
# # the front can make the user a requester
# def test_front_can_make_a_request():
# 	pass
# # the front can create the nft
# def test_front_can_create_the_nft_request():
# 	pass


# # ## Front v2
# # a user can create a request to ban someone
