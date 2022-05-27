import React from 'react';
// import logo from './logo.svg';
// import './App.css';
import {Header} from './components/Header'
import {Main} from './components/Main'
import { Container } from "@mui/material"

function App() {
  return (
  	<>
  		<Header/>
  	  <Container maxWidth="md">
        <Main />
      </Container>
  	</>

  );
}

export default App;
