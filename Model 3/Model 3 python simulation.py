import json  # Import JSON library for parsing JSON files
from web3 import Web3, EthereumTesterProvider  # Import Web3 tools for interacting with Ethereum
from eth_tester import EthereumTester, PyEVMBackend  # Import tools for Ethereum testing
from solcx import compile_standard, install_solc  # Import Solidity compiler tools

install_solc('0.8.0')  # Install the Solidity compiler version 0.8.0

# Compiles the Solidity contract specified by path and name
def compile_contract(file_path, contract_name):
    with open(file_path, 'r') as file:  # Open Solidity source file
        contract_source_code = file.read()  # Read the Solidity source code

    compiled_sol = compile_standard({  # Compile the Solidity code
        "language": "Solidity",
        "sources": {file_path: {"content": contract_source_code}},
        "settings": {
            "outputSelection": {  # Specify compiler output selections
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            }
        },
    }, solc_version='0.8.0')  # Use specified Solidity version

    contract_interface = compiled_sol['contracts'][file_path][contract_name]  # Extract the contract interface
    return contract_interface['abi'], contract_interface['evm']['bytecode']['object']  # Return ABI and bytecode

eth_tester = EthereumTester(PyEVMBackend())  # Create an Ethereum tester backend
web3 = Web3(EthereumTesterProvider(eth_tester))  # Create a Web3 instance connected to the Ethereum tester
web3.eth.default_account = eth_tester.get_accounts()[0]  # Set default account for transactions

# Deploy a compiled contract with initial balances for users
def deploy_contract(abi, bytecode, user1, user2, user3, user1_initial_balance, user2_initial_balance, user3_initial_balance):
    BettingContract = web3.eth.contract(abi=abi, bytecode=bytecode)  # Create a contract object from ABI and bytecode
    tx_hash = BettingContract.constructor(user1, user2, user3, user1_initial_balance, user2_initial_balance, user3_initial_balance).transact()  # Send transaction to deploy the contract
    tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)  # Wait for the transaction receipt
    return web3.eth.contract(address=tx_receipt.contractAddress, abi=abi)  # Return a contract instance

# Load match data from a JSON file specified by path
def load_world_cup_data(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:  # Open the JSON file for reading
        data = json.load(file)  # Load data from the JSON file
    return data  # Return the parsed data

# Function to simulate betting interactions based on user inputs
def simulate_betting_with_input(contract, match_data):
    print("List of all matches:")  # Print all match listings
    for round in match_data['rounds']:  # Iterate over each round
        for match in round['matches']:  # Iterate over each match in the round
            print(f"Match {match['num']}: {match['team1']['name']} vs {match['team2']['name']}")  # Print match details
    
    match_number = int(input("Select match number for betting (1 to 64): "))  # Prompt user to select a match number

    selected_match = None  # Initialize selected match variable
    for round in match_data['rounds']:  # Iterate over rounds to find the selected match
        for match in round['matches']:
            if match['num'] == match_number:  # Check if match number matches the input
                selected_match = match
                break
    if not selected_match:
        print("Match not found")  # Print error if match not found
        return

    user1_bet = int(input("Enter User1's bet result (0 for team1 win, 1 for draw, 2 for team2 win): "))  # Get User1's bet
    user1_bet_amount = int(input("Enter User1's bet amount: "))  # Get User1's bet amount
    contract.functions.setBetAndMatch(match_number, user1_bet_amount, user1_bet).transact({'from': web3.eth.accounts[0]})  # Transact User1's bet

    user2_bet = int(input("Enter User2's bet result (different from User1's bet): "))  # Get User2's bet
    user2_bet_amount = int(input("Enter User2's bet amount: "))  # Get User2's bet amount
    contract.functions.setUser2Result(user2_bet, user2_bet_amount).transact({'from': web3.eth.accounts[1]})  # Transact User2's bet

    user3_active = input("Is there a User3 participating? (yes/no): ").lower() == 'yes'  # Check if User3 is participating
    if user3_active:
        user3_bet = int(input("Enter User3's bet result (different from User1 and User2's bets): "))  # Get User3's bet
        user3_bet_amount = int(input("Enter User3's bet amount: "))  # Get User3's bet amount
        contract.functions.setUser3Result(user3_bet, user3_bet_amount).transact({'from': web3.eth.accounts[2]})  # Transact User3's bet

    match_result = 0 if selected_match['score1'] > selected_match['score2'] else 1 if selected_match['score1'] == selected_match['score2'] else 2  # Determine match result
    contract.functions.setMatchResult(match_result).transact()  # Set match result in the contract

    # Print the result of the match and update the balances after bets are settled
    result_description = "Draw" if match_result == 1 else f"{selected_match['team1']['name']} Won" if match_result == 0 else f"{selected_match['team2']['name']} Won"
    print(f"Selected Match Result: {match_result} ({selected_match['team1']['name']} vs {selected_match['team2']['name']}, Result: {selected_match['score1']}-{selected_match['score2']}, {result_description})")
    
    user1_balance_after = contract.functions.userBalances(web3.eth.accounts[0]).call()  # Get updated balance for User1
    user2_balance_after = contract.functions.userBalances(web3.eth.accounts[1]).call()  # Get updated balance for User2
    user3_balance_after = contract.functions.userBalances(web3.eth.accounts[2]).call() if user3_active else "Not participating"  # Get updated balance for User3

    print(f"After bet settlement, User1 Balance: {user1_balance_after}")  # Print updated balance for User1
    print(f"User2 Balance: {user2_balance_after}")  # Print updated balance for User2
    if user3_active:
        print(f"User3 Balance: {user3_balance_after}")  # Print updated balance for User3 if active

# Main execution flow
if __name__ == "__main__":
    abi, bytecode = compile_contract('BettingContract.sol', 'BettingContract')  # Compile contract and get ABI and bytecode
    user1_initial_balance = int(input("Enter User1's initial balance: "))  # Get initial balance for User1
    user2_initial_balance = int(input("Enter User2's initial balance: "))  # Get initial balance for User2
    user3_input = input("Enter User3's initial balance (leave blank if not participating): ")  # Get initial balance for User3 or determine non-participation
    user3 = web3.eth.accounts[2] if user3_input.strip() else web3.toChecksumAddress('0x0')  # Determine the address for User3
    user3_initial_balance = int(user3_input) if user3_input.strip() else 0  # Set initial balance for User3

    contract = deploy_contract(abi, bytecode, web3.eth.accounts[0], web3.eth.accounts[1], user3, user1_initial_balance, user2_initial_balance, user3_initial_balance)  # Deploy the contract with initial balances
    world_cup_data = load_world_cup_data('worldcup.json')  # Load World Cup match data
    simulate_betting_with_input(contract, world_cup_data)  # Run the betting simulation
