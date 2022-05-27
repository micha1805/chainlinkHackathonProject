import React from 'react';
import ReactDOM from 'react-dom/client';
import { ChainId, DAppProvider } from "@usedapp/core"
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>

      <DAppProvider config={{
      // supportedChains: [ChainId.Kovan, ChainId.Rinkeby, 1337]
      supportedChains: [ChainId.Kovan],
      notifications: {
        expirationPeriod: 1000,
        checkInterval: 1000
      }
    }}>
   		<App />
    </DAppProvider>

  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
