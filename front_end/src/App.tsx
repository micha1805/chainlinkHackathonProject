import React from 'react';
import { ChainId, DAppProvider } from "@usedapp/core"
import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <DAppProvider config={{
      // supportedChains: [ChainId.Kovan, ChainId.Rinkeby, 1337]
      supportedChains: [ChainId.Kovan],
      notifications: {
        expirationPeriod: 1000,
        checkInterval: 1000
      }
    }}>
	    <div className="App">
	      <header className="App-header">
	        <img src={logo} className="App-logo" alt="logo" />
	        <p>
	          Edit <code>src/App.tsx</code> and save to reload.
	        </p>
	        <a
	          className="App-link"
	          href="https://reactjs.org"
	          target="_blank"
	          rel="noopener noreferrer"
	        >
	          Learn React
	        </a>
	      </header>
	    </div>
	   </DAppProvider>
  );
}

export default App;
