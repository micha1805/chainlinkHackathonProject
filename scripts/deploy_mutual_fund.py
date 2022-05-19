from brownie import accounts, MutualFund
from scripts.helpful_scripts import deploy_mutual_fund

def add_users_to_contract():
	mutual_fund = MutualFund[-1]
	accounts.load('user0')
	accounts.load('user1')
	accounts.load('user2')
	accounts.load('user3')
	accounts.load('user4')
	accounts.load('user5')
	accounts.load('user6')
	accounts.load('user7')
	accounts.load('user8')
	accounts.load('user9')
	i = 0;
	for account in accounts:
		print(f" account[{i}] = {account}")
		i+=1
		mutual_fund.enter({"from":account})
	print(mutual_fund)

def main():
	# deploy_mutual_fund()
	add_users_to_contract()
