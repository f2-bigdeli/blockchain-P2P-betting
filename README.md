# Blockchain P2P Betting

## Overview
This repository contains three models of blockchain-based peer-to-peer (P2P) betting systems, implemented as smart contracts in Solidity. Each model demonstrates a unique betting scenario and has been tested using Ethereum testnet and Metamask wallet. The project includes additional Python scripts for simulating smart contract interactions using web3 and eth-tester libraries.

## Files

### Smart Contracts
- **Model 1.sol**: A simple lottery system where three participants can place their bets, and one is randomly chosen as the winner. The test ether is transferred from the losers' accounts to the winner's account.
- **Model 2.sol**: A betting system where users place bets on the outcome of a match. The test ether is transferred from the losers' accounts to the winner's account based on the match result.
- **BettingContract.sol**: Used in Model 3 for simulating betting on World Cup 2018 matches using Python.

### Python Script
- **Model 3 python simulation.py**: Simulates the interaction with the `BettingContract.sol` smart contract using web3 and eth-tester libraries. It uses a dataset of World Cup 2018 results to simulate the role of an oracle in smart contracts.

### Dataset
- **worldcup.json**: Contains the results of World Cup 2018 matches used for simulating oracle data in Model 3.

### Documentation
- **P2P Betting Smart Contracts.docx**: A Word document containing screenshots of the models' outputs, flowcharts of the models' structures, and a comparative table of the three models.

## Description of Models

### Model 1: Lottery System
- **File**: Model_1.sol
- **Description**: Simulates a simple lottery system where three participants can place their bets. One participant is randomly chosen as the winner, and test ether is transferred from the losers' accounts to the winner's account.
- **Environment**: Designed and tested in Remix using Ethereum testnet and Metamask.

### Model 2: Match Betting System
- **File**: Model_2.sol
- **Description**: Allows users to place bets on the outcome of a match. After the match result is determined, test ether is transferred from the losers' accounts to the winner's account.
- **Environment**: Designed and tested in Remix using Ethereum testnet and Metamask.

### Model 3: World Cup Match Betting with Oracle
- **Files**: BettingContract.sol, Model_3_python_simulation.py, worldcup.json
- **Description**: Uses a dataset of World Cup 2018 results to simulate match betting. Users place bets on a selected match, and the results from the dataset simulate the role of an oracle to determine the winner and transfer funds accordingly.
- **Environment**: Runs in a Python environment using web3 and eth-tester libraries.

## How to Use

### Prerequisites
- **Solidity**: Smart contract language used for the models. [Learn more](https://soliditylang.org/)
- **Remix IDE**: Online IDE for developing, deploying, and testing smart contracts. [Remix IDE](https://remix.ethereum.org/)
- **Metamask**: Browser extension for interacting with Ethereum blockchain. [Download Metamask](https://metamask.io/)
- **Python**: Ensure Python is installed. [Download Python](https://www.python.org/downloads/)
- **web3.py**: Python library for interacting with Ethereum. Install using `pip install web3`
- **eth-tester**: Python library for testing Ethereum-based applications. Install using `pip install eth-tester`

### Running the Models

#### Model 1 and Model 2
1. **Open Remix IDE**.
2. **Deploy the smart contracts** (`Model_1.sol` and `Model_2.sol`) in the Remix environment.
3. **Use Metamask** to connect to the Ethereum testnet.
4. **Interact with the contracts** through Remix to simulate betting and winning scenarios.

#### Model 3
1. **Ensure Python and required libraries** (web3 and eth-tester) are installed.
2. **Place `BettingContract.sol`, `Model_3_python_simulation.py`, and `worldcup.json`** in the same directory.
3. **Run the Python script**:
   ```bash
   python Model_3_python_simulation.py
