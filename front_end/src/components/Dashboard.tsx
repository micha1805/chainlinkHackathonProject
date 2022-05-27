import React, { useState, useEffect } from "react"
import { Input, Button, CircularProgress, Snackbar, Alert } from "@mui/material"
import {useEnter} from "../hooks/useEnter"
import {useFetchBalance} from "../hooks/useFetchBalance"
import { useNotifications } from "@usedapp/core"
import { useContractFunction, useEthers, useCall } from "@usedapp/core"
import MutualFund from "../chain-info/contracts/MutualFund.json"
import { Contract } from "@ethersproject/contracts"
import { constants, utils } from "ethers"
import networkMapping from "../chain-info/deployments/map.json"

export const Dashboard = () => {

	// const	{account, chainId} = useEthers()


	// // function to get balance of user
	// const fetchBalance = () => {

	// 	const { abi } = MutualFund
	// 	const mutualFundAddress = chainId ? networkMapping[String(chainId)]["MutualFund"][0] : constants.AddressZero
	// 	const mutualFundInterface = new utils.Interface(abi)
	// 	const MutualFundContract = new Contract(mutualFundAddress, mutualFundInterface)


	//   const { value, error } = useCall(mutualFundAddress && {
	//      contract: MutualFundContract,
	//      method: 'userBalance',
	//      args: [account]
	//    }) ?? {}

	//   if(error) return error
	//   return value
	// }



	// hooks

	const [amountOnEnter, setAmountOnEnter] = useState<number | string | Array<number | string>>(0)

	const [userBalanceOnContract, setUserBalanceOnContract] = useState(0)

	const {enterContract, enterContractState} = useEnter()

  const { notifications } = useNotifications()

  const [ showEnterSuccess, setShowEnterSuccess ] = useState(false)

  const {value, error} = useFetchBalance()



  // handler functions

  const handleCloseSnack = () => {
      setShowEnterSuccess(false)
  }
	const handleEnterChange = (event: React.ChangeEvent<HTMLInputElement>) => {
		const newAmount = event.target.value === "" ? "" : Number(event.target.value)
		setAmountOnEnter(newAmount)
	}
	const handleEnterSubmit = () => {
		console.log(amountOnEnter)
		return enterContract({ value: amountOnEnter.toString() })
	}

	const handleFetchBalance = () =>  {
		// setUserBalanceOnContract(userBalance)
	}


	// useEffect

  useEffect(() => {
    if (
        notifications
            .filter((notification) => notification.type === "transactionSucceed" && notification.transactionName === "Enter contract")
            .length > 0
    ) {
        setShowEnterSuccess(true)
    }else{
    	setShowEnterSuccess(false)
    }



  }, [notifications, setShowEnterSuccess]);

	useEffect( ()=>{
		console.log(enterContractState.errorMessage ? enterContractState.errorMessage : enterContractState.status)

	}, [enterContractState])

	// other variables

	let txEnterPending = enterContractState.status === "Mining"
	let txFetchPending = false
	// let txFetchPending = fetchBalanceState.status === "Mining"

		return(
			<div className="dashboard-component">

				{/*Enter contract*/}
				<div className="enter_contract">

					<p>Enter contract with following amount (WEI):</p>
					<Input onChange={handleEnterChange} />
					<Button
						color="primary"
						size="large"
						onClick={handleEnterSubmit}
						disabled={txEnterPending}
					>{txEnterPending ? <CircularProgress size={26} /> : "Enter contract"}
					</Button>

	            <Snackbar
	                open={showEnterSuccess}
	                autoHideDuration={5000}
	                onClose={handleCloseSnack}
	            >
	                <Alert onClose={handleCloseSnack} severity="success">
	                    You entered the Mutual Fund succesfully!
	                </Alert>
	            </Snackbar>

				</div>

				{/*Get balance on the contract*/}
				<div className="getCurrentBalance">
					<span className="userBalanceOnContract"> Current User balance on the Contract : {value} ETH</span>
				<Button
						color="primary"
						size="large"
						onClick={handleFetchBalance}
						disabled={true}
					>Fetch data
					</Button>

				</div>
			</div>)

	}
