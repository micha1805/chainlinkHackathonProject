import { useEthers } from "@usedapp/core"
import { Button } from "@mui/material"




export const Header = () => {

const { account, activateBrowserWallet, deactivate } = useEthers()
const isConnected = account !== undefined

	return (
		<div className="header-component">

		{isConnected ? (


			<Button color="primary" onClick={deactivate} variant="contained">
			Disconnect
			</Button>

			) : (
			<Button color="primary" onClick={() => activateBrowserWallet()} variant="contained">
			Connect
			</Button>
			)
		}
		</div>
		)

}
