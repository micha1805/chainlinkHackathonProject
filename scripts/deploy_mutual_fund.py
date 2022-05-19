from subprocess import Popen, PIPE
from brownie import accounts, MutualFund
from scripts.helpful_scripts import deploy_mutual_fund

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
	add_users_to_contract()
