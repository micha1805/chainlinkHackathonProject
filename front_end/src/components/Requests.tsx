import React, { useState, useEffect } from "react"
import { Input, Button, CircularProgress, Snackbar, Alert } from "@mui/material"
import { useNotifications } from "@usedapp/core"
import { useMakeRequest } from "../hooks/useMakeRequest"


export const Requests = () => {

	// hooks
  const { notifications } = useNotifications()

	const [amountRequested, setAmountRequested ] = useState<number | string | Array<number | string>>(0)

  const [ showSubmitRequestSuccess, setSubmitRequestSuccess ] = useState(false)

	const {submitARequest, submitARequestState} = useMakeRequest()

	// handlers
	const handleAmountRequested = (event: React.ChangeEvent<HTMLInputElement>) =>{
		const newAmount = event.target.value === "" ? "" : Number(event.target.value)
		setAmountRequested(newAmount)
	}

	const handleRequestSubmit = () => {
		return submitARequest(amountRequested.toString())
	}

	const handleCloseSnack = () => {
		setSubmitRequestSuccess(false)
	}

	// useEffect


  useEffect(() => {
    if (
        notifications
            .filter((notification) => notification.type === "transactionSucceed" && notification.transactionName === "submit a request")
            .length > 0
    ) {
        setSubmitRequestSuccess(true)
    }else{
    	setSubmitRequestSuccess(false)
    }



  }, [notifications, setSubmitRequestSuccess]);


  // other variables
	let txPending = submitARequestState.status === "Mining"




	return(
		<div className="request-component">

			<h2>Make a Request</h2>

			<span>
				<p>Amount requested: </p>
				<Input onChange={handleAmountRequested} />
				<Button
						color="primary"
						size="large"
						onClick={handleRequestSubmit}
						disabled={txPending}
					>{txPending ? <CircularProgress size={26} /> : "Make a Request"}
					</Button>

	            <Snackbar
	                open={showSubmitRequestSuccess}
	                autoHideDuration={5000}
	                onClose={handleCloseSnack}
	            >
	                <Alert onClose={handleCloseSnack} severity="success">
	                    Your request was sent succesfully!
	                </Alert>
	            </Snackbar>
			</span>
		</div>
		)

}
