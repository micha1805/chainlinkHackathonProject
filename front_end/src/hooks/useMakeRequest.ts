import { useContractFunction, useEthers } from "@usedapp/core"
import networkMapping from "../chain-info/deployments/map.json"
import MutualFund from "../chain-info/contracts/MutualFund.json"
import { constants, utils } from "ethers"
import { Contract } from "@ethersproject/contracts"

export const useMakeRequest = () => {

	const	{account, chainId} = useEthers()
	const { abi } = MutualFund
	const mutualFundAddress = chainId ? networkMapping[String(chainId)]["MutualFund"][0] : constants.AddressZero
	const mutualFundInterface = new utils.Interface(abi)
	const MutualFundContract = new Contract(mutualFundAddress, mutualFundInterface)

	// enter the contract
	const { send: submitARequest, state: submitARequestState} =
			useContractFunction(
				MutualFundContract,
				"submitARequest",
				{transactionName : "submit a request"}
				)

return {submitARequest, submitARequestState}


}
