import { useContractFunction, useEthers } from "@usedapp/core"
import networkMapping from "../chain-info/deployments/map.json"
import MutualFund from "../chain-info/contracts/MutualFund.json"
import { constants, utils } from "ethers"
import { Contract } from "@ethersproject/contracts"

export const useEnter = () => {

	const	{account, chainId} = useEthers()
	const { abi } = MutualFund
	const mutualFundAddress = chainId ? networkMapping[String(chainId)]["MutualFund"][0] : constants.AddressZero
	const mutualFundInterface = new utils.Interface(abi)
	const MutualFundContract = new Contract(mutualFundAddress, mutualFundInterface)

	// enter the contract
	const { send: enterContract, state: enterContractState} =
			useContractFunction(
				MutualFundContract,
				"enter",
				{transactionName : "Enter contract"}
				)

return {enterContract, enterContractState}


}
