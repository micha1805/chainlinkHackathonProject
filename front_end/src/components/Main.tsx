import { useEthers } from "@usedapp/core"
import { constants } from "ethers"
import helperConfig from "../helper-config.json"
import brownieConfig from "../brownie-config.json"
import networkMapping from "../chain-info/deployments/map.json"


export const Main = () => {

const { account, activateBrowserWallet, deactivate } = useEthers()
const isConnected = account !== undefined

    const { chainId } = useEthers()
    const networkName = chainId ? helperConfig[chainId] : "dev"
    const mutualFund = chainId ? networkMapping[String(chainId)]["MutualFund"][0] : constants.AddressZero

    return (
        <>
        	<div>
        		Hello {isConnected ? mutualFund : "Not connected"}
        	</div>

        </>
    )
}
