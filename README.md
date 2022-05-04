# Chainlink Hackathon Spring 2022 - Plainchamp


## Mutual Fund

The project consists in creating a Smart Contract of a mutual fund.

Anyone can enter the fund and request a sum under some conditions.



## User stories

- A user needs to pay a monthly fee, anything greater than 0, the value is still important because it sets the amount that can be requested if needed. If the total contribition is very small, then the amount requestable is smaller too. The

- A user can be selected as a juree to check someone else's request. If the user does not answer in time (set to one month currently), he is banned from the fund and all his previous contribution is kept in the fund. He can come back, but all his contributions are set back to 0, which is important because it sets the total amounta user can request.





## Request conditions

The total amount requested cannot be greater than 10 times his total contribtion, if this is still the case but that amount is greater than 1% of the fund, than this last value will be the one that can be granted.

A request NFT is created, containing all the details of the request.

### NFT structure

For each request an NFT is mint, that way liars are spotted for the eternity!



```json
fullname and REAL ID
request decription

urls of information
```


## Ban conditions

A juree does not answer the request.
A requester is found out to have lied.

When a user is


## Random jurees

For any request a random sample of jurees is chosen in the array od users. The randomness uses the Chainlink VRF service.

By default it is setup to 100 people randmoly chosen.

## Improvements

- Incentives for jurees to make the good choice, and not just clickig yes all the time ? Ban ?
- Incentives for not just plainly lying on the request ? Just a ban??
- VRF for each 100 juree ? Or one (real) random number plus pseudo random number to get all the 99 aother jurees ?


## Technologies used

- Solidity on Ethereum.
- brownie as the back end framework
- Chainlink VRF for selectong randm jurees, chainlink keeper to do the cron job of checking each month if each user has paid his contributtion, and also check if each juree has answered in time.
- React for the FrontEnd


## admin powers

For now the contract has and admin, a single account. Ideally this admin capacity should be distributed via an admin contract for instance, where all the changes should be submitted to a vote. For the purpose of the hackathon, I just made a simple single user, which is not ideal of course regarding decentralization.

The admin can set the following parameters :

- number of jurees
- delay to judge a request
- max amount per request according to user balance
- max amount per request according to MutulaFund total balance (percentage of total)

