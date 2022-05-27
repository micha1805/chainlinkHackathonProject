# Chainlink Hackathon Spring 2022 - Plainchamp


## Mutual Fund

The project consists in creating a Smart Contract of a mutual fund.

Anyone can enter the fund and request a sum.



## How does it work?

You enter the fund via the `enter` function.

When you enter the contract you can submit a request using the `submitARequest` function.

When you call this `submitARequest` function this creates a request struct containing the following informations :
- the amount desired
- your address (to transfer the funds)
- an array of random users that will constitute the jury memebers that will decide if your request is valid or not. (its length is fixed to 5)


(Ideally some information about the request should be inserted but it's not yet implemented.)


When a request is made each jury member must vote for that specific request using the function `voteForARequest`, when each jury member has voted the amount requested is transfered to the requester or nothing is done and the status of the request is just set to refused.



## How to use

Once the repo is pulled add to root of the project an `.env` file containing the following informations :


```bash
export PRIVATE_KEY=0x123456789
export WEB3_INFURA_PROJECT_ID=LOREM1234
export ETHERSCAN_TOKEN=LOREM1234

```


### Deploy

To deploy, for instance on Kovan, run the following :

` brownie run scripts/deploy_mutual_fund.py --network kovan`

### Tests

My whole test are in the test scripts : tests/test_unit_tests_list.py

If you want to run the tests, on the root folder run :
`brownie test`


### Front end

If you want to run the front end, go to the `front_end` folder, first install the dependencies :
`npm install`

Then launch the app :
`npm start`

It should run on localhost:3000


If you have some troubles, try the following, to fetch to the front-end folder the information from the backend :
`brownie run scripts/update_front_end.py`




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

Ideally the random array of users that constitutes the jury members should really be random using Chainlink VRF but as I had troubles testing it, it's simply hardcoded for now to the same jury members all the time.


## Technologies used

- Solidity on Ethereum.
- brownie as the back end framework
- Chainlink VRF for selecting randm jurees (not yet actually)
- React/TypeScript for the FrontEnd


## admin powers

For now the contract has and admin, a single account. Ideally this admin capacity should be distributed via an admin contract for instance, where all the changes should be submitted to a vote. For the purpose of the hackathon, I just made a simple single user, which is not ideal of course regarding decentralization.
