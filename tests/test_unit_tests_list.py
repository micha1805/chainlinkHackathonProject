from brownie import accounts, network, MutualFund, exceptions
import pytest
from scripts.helpful_scripts import (
	LOCAL_BLOCKCHAIN_ENVIRONMENTS,
	get_account,
	get_contract,
	)

# ## list of tests todo



# ## BACK


# contract has and admin (ideally no but it's for the hackathon purpose, to keep a grip on the deployed contract if necessary)
def test_contract_has_an_owner():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
		pytest.skip("Only for local environnment testing")

	account = get_account()
	mutual_fund = MutualFund.deploy({"from": account})
	owner = mutual_fund.owner()

	assert( account == owner)

# a user can enter contract
def test_a_user_can_enter_contract():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
	   pytest.skip("Only for local environnment testing")
	# create contract and owner
	owner = get_account()
	mutual_fund = MutualFund.deploy({"from": owner})

	# create a random user
	random_user = get_account(2)


	# attempt to enter the contract :
	mutual_fund.enter({"from": random_user})

	# get user frome the array :
	assert( mutual_fund.users(0) == random_user)




# a user can pay and enter the contract
def test_a_user_can_pay_while_entering_contract():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local environnment testing")

    TICKET_VALUE = 10000000000 #random value
    # create contract and owner
    owner = get_account()
    mutual_fund = MutualFund.deploy({"from": owner})

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

# The owner can change settings
def test_owner_can_change_settings():

	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
		pytest.skip()


	# create contract, owner and simple user
	owner = get_account()
	simple_user = get_account(2)
	mutual_fund = MutualFund.deploy({"from": owner})

	# change settings
	new_jurees_number = 33
	new_multiple = 6

	mutual_fund.modifyJureesNumber(new_jurees_number, {"from": owner})
	mutual_fund.modifyMultiple(new_multiple, {"from": owner})

	assert(mutual_fund.jurees_number() == new_jurees_number)
	assert(mutual_fund.max_multiple() == new_multiple)


# Non owner cannot change settings
def test_simple_user_cannot_change_settings():
	if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
		pytest.skip()

	# change settings
	new_jurees_number = 33
	new_multiple = 6

	# create contract, owner and simple user
	owner = get_account()
	simple_user = get_account(2)
	mutual_fund = MutualFund.deploy({"from": owner})

	with pytest.raises(exceptions.VirtualMachineError):
		mutual_fund.modifyJureesNumber(new_jurees_number, {"from": simple_user})

	with pytest.raises(exceptions.VirtualMachineError):
		mutual_fund.modifyMultiple(new_multiple, {"from": simple_user})




# a user can quit contract
def test_a_user_can_quit_contract():
	pass
# a user can pay a monthly fee
def test_a_user_can_pay_monthly_fee():
	pass
# a user is kicked if he doesn't pay (use of chailink keeper cron)
def test_banning_a_user_after_no_payment():
	pass
# mock of chainink keeper ?
# can make a request
def test_a_user_can_make_a_request():
	pass
# the request is an nft
def test_the_request_is_a_NFT():
	pass
# the nft contains the correct fields
def test_the_request_nft_has_the_correct_fields():
	pass
# can select 100 random users if nb users > 100
def test_the_contract_can_select_100_random_users_if_nb_user_is_greater_than_100():
	pass
# can select 100 random users if nb users < 100
def test_the_contract_cannnot_select_100_random_users_if_nb_user_is_smaller_than_100():
	pass
# if the juree does not answer i due time he is kicked of the contract
def test_juree_is_kicked_out_if_he_does_not_answer_in_due_time():
	pass
# if > 50% of the jurees agree to the request the money is sent
def test_therequest_is_accepted_to_the_majority():
	pass
# the money is actually sent to the requester, and the amount is correct
def test_the_money_is_correctly_received():
	pass
# the full history of requests is publicly available, just an array of all the nfts created
def test_full_history_of_requests_is_public():
	pass


# ## BACK v2 :
# the juree can modify the amount requested ?
# the amount requested MUST be this : min(1% of total fund, 10x the total paid by the requester)
# the admin can change some parameters (% of total fund per request, multiplier of requestant according to how much he has paid in total)
# if a user quits or is being kicked out, he CANNOT gets his funds back and needs to go back fro beginning (it is important because the amout requestable is proportional to the total contribution of the user)
# a user can be kicked if he has lied : a new nft is created with the information of the fake request (actually the nft created), a new request is sent to 100 people and the judge if the request was actually a lie and the user must be kicked.





# ## FRONT
# the front can make the user enter AND quit the contract
def test_front_can_make_the_user_enter_and_quit_the_contract():
	pass
# the front can access the contract
def test_front_can_access_the_contract():
	pass
# the front can check if the user has become a juree
def test_front_can_check_if_user_has_become_a_juree():
	pass
# the front can read the nft and its content
def test_front_can_read_the_nft_request():
	pass
# the front can make the user a requester
def test_front_can_make_a_request():
	pass
# the front can create the nft
def test_front_can_create_the_nft_request():
	pass


# ## Front v2
# a user can create a request to ban someone
