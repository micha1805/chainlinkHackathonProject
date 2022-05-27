from scripts.helpful_scripts import get_account, get_contract
from brownie import MutualFund, config, network, web3, accounts
import yaml, json, os, shutil

def update_front_end():

	# send the build folder
	###################################################################
	# FAIRE TRES ATTENTION, LE SECOND PATH SERA INEGRALEMENT EFFACE ! #
	###################################################################
	folder_dest_to_erase = "./front_end/src/chain-info"
	copy_folders_to_front_end("./build", folder_dest_to_erase)
	# sending the front end config in JSON format
	with open("brownie-config.yaml", "r") as brownie_config:
		# convert the yaml into a python dictionary
		config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
		with open("./front_end/src/brownie-config.json", "w") as brownie_config_json:
			json.dump(config_dict, brownie_config_json)
	print("Front end updated!")


def copy_folders_to_front_end(src, dest):
	if os.path.exists(dest):

		#####################
		# ATTENTION !!!!!!  #
		#####################

		# s'il y a quelque chose on efface tout
		shutil.rmtree(dest)
	shutil.copytree(src, dest)


def deploy_mutual_fund(index=None, totalUsers=1):
	# account = get_account(id="freecodecamp-account")
	account = get_account(index)

	# check the constructor to get all the needed parameters
	mutual_fund = MutualFund.deploy(
		get_contract("vrf_coordinator").address,
		get_contract("link_token").address,
		config["networks"][network.show_active()]["fee"],
		config["networks"][network.show_active()]["keyhash"],
		{"from": account},
		# verify is set to default = False
		publish_source=config["networks"][network.show_active()].get("verify", False),
	)

	# add 9 other accounts :
	number_of_users = totalUsers - 1 # -1 because we alreadu have an owner
	my_integer_list = list(range(number_of_users))

	value_to_send_to_contract_per_user = web3.toWei(1, "ether")

	for i in my_integer_list:
		new_account = get_account(index=i+1)
		mutual_fund.enter({"value": value_to_send_to_contract_per_user, "from": new_account})


	print(f"Deployed Mutual Fund contract with 1 owner and {number_of_users} other users")
	return mutual_fund

def load_account(index):

	# load accounts from 'user0' to 'user9'
	# YOU NEED TO HAVE LOADED THESE ACCOUNTS IN BROWNIE WITH :
	# brownie accounts new user0
	# brownie accounts new user1
	# brownie accounts new user2
	# etc.
	# the passwords will still be asked while loading them though.

	account_name = "user"+str(index)
	accounts.load(account_name)


def add_users_to_contract():
	mutual_fund = MutualFund[-1]

	for index in range(9):
		load_account(index)

	i = 0;
	for account in accounts:
		print(f" account[{i}] = {account}")
		i+=1
		mutual_fund.enter({"from":account})
	print(mutual_fund)

def main():
	deploy_mutual_fund()
	update_front_end()
	add_users_to_contract()
