import React from 'react'
import { useContractFunction, useEthers, useCall } from "@usedapp/core"
import MutualFund from "../chain-info/contracts/MutualFund.json"
import { Contract } from "@ethersproject/contracts"
import { constants, utils } from "ethers"
import networkMapping from "../chain-info/deployments/map.json"


export const useFetchBalance = () => {

	const	{account, chainId} = useEthers()
	const { abi } = MutualFund
	const mutualFundAddress = chainId ? networkMapping[String(chainId)]["MutualFund"][0] : constants.AddressZero
	const mutualFundInterface = new utils.Interface(abi)
	const MutualFundContract = new Contract(mutualFundAddress, mutualFundInterface)


  const { value, error }:any = useCall(mutualFundAddress && {
     contract: MutualFundContract,
     method: 'userBalance',
     args: []
   }) ?? {}

	// console.log("ACCOUNT", account)
	// console.log("mutualFundAddress", mutualFundAddress)
 //  console.log("VALUE", value)
 //  console.log("ERROR", error)
  return {value, error}





}
