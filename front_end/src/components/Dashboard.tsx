import React, { useState, useEffect } from "react"
import { Input, Button, CircularProgress, Snackbar, Alert } from "@mui/material"
import {useEnter} from "../hooks/useEnter"
import { useNotifications } from "@usedapp/core"

export const Dashboard = () => {




	// hooks

	const [amountOnEnter, setAmountOnEnter] = useState<number | string | Array<number | string>>(0)

	const [userBalanceOnContract, setUserBalanceOnContract] = useState(0)

	const {enterContract, enterContractState} = useEnter()

  const { notifications } = useNotifications()

  const [ showEnterSuccess, setShowEnterSuccess ] = useState(false)


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
		return enterContract()
	}

	const handleFetchBalance = () =>  {
		setUserBalanceOnContract(userBalanceOnContract +1)
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

					<p>Enter contract with following amount :</p>
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
					<span className="userBalanceOnContract"> Current User balance on the Contract : {userBalanceOnContract} ETH</span>
				<Button
						color="primary"
						size="large"
						onClick={handleFetchBalance}
						disabled={txFetchPending}
					>Fetch data
					</Button>

				</div>
			</div>)

	}
