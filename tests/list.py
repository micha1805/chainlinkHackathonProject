# ## list of tests todo



# ## BACK


# contract has and admin (ideally no but it's for the hackathon purpose, to keep a grip on the deployed contract)
# can enter contract
# can quit contract
# can pay a monthly fee
# be kicked of yo don't pay (use of chailink keeper cron)
# mock of chainink keeper ?
# can make a request
# the request is an nft
# the nft contains the correct fields
# can select 100 random users if nb users > 100
# can select 100 random users if nb users < 100
# if the juree does not answer i due time he is kicked of the contract
# if > 50% of the jurees agree to the request the money is sent
# the money is actually sent to the requester, and the amount is correct
# the amount requested MUST be this : min(1% of total fund, 10x the total paid by the requester)
# the juree can modify the amount requested ?
# if a user quits or is being kicked out, he CANNOT gets his funds back and needs to go back fro beginning (it is important because the amout requestable is proportional to the total contribution of the user)
# the full history of requests is publicly available, just an array of all the nfts created



# ## v2 :
# the admin can change some parameters (% of total fund per request, multiplier of requestant according to how much he has paid in total)





# ## FRONT
# the front can make the user enter AND quit the contract
# the front can access the contract
# the front can check if the user has become a juree
# the front can read the nft and its content
# the front can make the user a requester
# the front can create the nft
