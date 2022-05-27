import React, { useState } from "react"
import { useEthers } from "@usedapp/core"
import { constants } from "ethers"
import { Box, Tab } from "@mui/material"
import { TabContext, TabList, TabPanel } from "@mui/lab"

import helperConfig from "../helper-config.json"
import brownieConfig from "../brownie-config.json"
import networkMapping from "../chain-info/deployments/map.json"
import {Dashboard} from './Dashboard'
import {Requests} from './Requests'
import {Jury} from './Jury'


export const Main = () => {

const { account, activateBrowserWallet, deactivate } = useEthers()
const isConnected = account !== undefined

    const { chainId } = useEthers()
    const networkName = chainId ? helperConfig[chainId] : "dev"
    const mutualFund = chainId ? networkMapping[String(chainId)]["MutualFund"][0] : constants.AddressZero

    const handleChange = (event: React.ChangeEvent<{}>, newValue: string) => {
        setSelectedTab(parseInt(newValue))
    }

    const [selectedTab, setSelectedTab] = useState<number>(1)

    return (
        <>
        	<div className="main-component">
        		MutualFund address is (Kovan): {isConnected ? mutualFund : "Not connected"}
        	</div>

      		<TabContext value={selectedTab.toString()}>
					  <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
					    <TabList onChange={handleChange} aria-label="lab API tabs example">
					      <Tab label="Dashboard" value="1" />
					      <Tab label="Requests" value="2" />
					      <Tab label="Jury" value="3" />
					    </TabList>
					  </Box>
					  <TabPanel value="1">
					  	<Dashboard/>
					  </TabPanel>
					  <TabPanel value="2">
					  	<Requests/>
					  </TabPanel>
					  <TabPanel value="3">
					  	<Jury/>
					  </TabPanel>
					</TabContext>

        </>
    )
}
