# Chainlink Hackathon Spring 2022 - Michel Plainchamp


## Mutual Fund

The project consists in creating a Smart Contract of a mutual fund on Ethereum

Anyone can enter the fund and request a sum from that contract.

The sum is allowed or not according to the votes of a random array of users, who become jury members.



## How does it work?

You enter the fund contract via the `enter` function.

When you enter the contract you can submit a request using the `submitARequest` function.

When you call this `submitARequest` function this creates a request struct containing the following informations :
- the amount desired
- your address (to transfer the funds)
- an array of random users that will compose the jury members that will decide if your request is valid or not. (its length is fixed to 5)


(Ideally some information about the request should be inserted but it's not yet implemented.)


When a request is made each jury member must vote for that specific request using the function `voteForARequest`, when each jury member has voted the amount requested is transfered to the requester or nothing is done and the status of the request is just set to refused.



## How to use

Once the repo is pulled, you need to add to the root of the project an `.env` file containing the following informations :

(example)
```bash
export PRIVATE_KEY=0x123456789
export WEB3_INFURA_PROJECT_ID=LOREM1234
export ETHERSCAN_TOKEN=LOREM1234

```

After you saved your `.env` file read it with the following :

```bash
source .env
```


### Deploy

To deploy, for instance on Kovan, run the following :

`brownie run scripts/deploy_mutual_fund.py --network kovan`

### Tests

My whole test are in the following test script : `tests/test_unit_tests_list.py`

If you want to run the tests, on the root folder run :
`brownie test`


### Front end

If you want to run the front end, go to the `front_end` folder, first install the dependencies :
`npm install`

Then launch the app :
`npm start`

It should run on `localhost:3000`


If you have some troubles, try the following, to fetch to the front-end folder the information from the backend :
`brownie run scripts/update_front_end.py`


The front-end is not complete, for now it's only possible to enter the contract (and fund it at the same time) and submit a request.

#### Enter the contract

First connnect using the Connect Button.

To enter the contract go to the Dashboard tab, fill in the amount you want to send to the contract then click Enter, you should receive a notification message stating that you entered succesfully the Mutual Fund.

#### Submit a request

Go to the Requests tabs.

Fill in the amount (in WEI) you want to request, then click on make a request. You should get a notification about the success of the transaction.


## Note on automatic insertion of users while deploying

In the deploy script there is a `load_accounts` functions used to load 10 brownie user accounts named the following :

`user0
user1
user2
user3
user4
user5
user6
user7
user8
user9`


It's a ways of always pushing 10 users in the contract just after deployment.

It's actually not mandatory, you can comment the function `add_users_to_contract`in the deploy script to skip this auto load, but because of the way the jury members arrays is hardcoded the contract needs at least 9 users to create a request properly. You can choose to add them manually or using this method.

## Notes

Ideally the random array of users that composes the jury members should really be random using Chainlink VRF but as I had troubles testing it, it's simply hardcoded for now to the same jury members all the time.


## Stack used

- Solidity on Ethereum.
- Remix for testing various stuff on Solidity
- brownie as the back end framework
- Chainlink VRF for selecting random jury members (not yet actually)
- React/TypeScript with useDAPP for the FrontEnd


## admin powers

For now the contract has and admin, a single account. Ideally this admin capacity should be distributed via an admin contract for instance, where all the changes should be submitted to a vote. For the purpose of the hackathon, I just made a simple single user, which is not ideal of course regarding decentralization.


## Last word !

Building this all alone, on the side, while still having a full time day job and a young child to take care of, could explain some parts of the incompleteness of this project (especially the front-end and the VRF), but whatever it was a nice experience !

Have a good day whoever reads this !


