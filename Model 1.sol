// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contract definition for a simple lottery game
contract LotteryContract {
    address public manager; // Address of the lottery manager
    address payable[] public candidates; // Dynamic array of participants
    address payable public winner; // Address of the winning participant
    uint256 public constant MIN_BET_AMOUNT = 0.000001 ether; // Minimum bet amount required to participate
    uint256 public betAmount; // Stores the bet amount for comparison
    bool public betAmountLocked; // Flag to lock the bet amount after the first valid entry

    // Contract constructor sets the manager to the address that deployed the contract
    constructor() {
        manager = msg.sender;
    }

    // Receive function to handle incoming Ether transactions
    receive() external payable {
        if (!betAmountLocked) {
            require(msg.value >= MIN_BET_AMOUNT, "Bet is below the minimum required amount.");
            betAmount = msg.value; // Set the first valid bet amount
            betAmountLocked = true; // Lock the bet amount after the first bet
        } else {
            require(msg.value == betAmount, "All bets must match the first bet amount.");
        }
        candidates.push(payable(msg.sender)); // Add the sender to the list of candidates
    }

    // Function for the manager to check the contract's balance
    function getBalance() public view returns (uint) {
        require(msg.sender == manager, "Only the manager can check the balance.");
        return address(this).balance;
    }

    // Generates a pseudo-random number based on block variables
    function getRandom() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, candidates.length)));
    }

    // Function to select a winner among candidates
    function pickWinner() public {
        require(msg.sender == manager, "Only the manager can pick a winner.");
        require(candidates.length >= 3, "Not enough candidates to pick a winner.");

        uint r = getRandom();
        uint index = r % candidates.length; // Calculate a random index based on the random number
        winner = candidates[index]; // Set the winner
        
        winner.transfer(getBalance()); // Transfer the entire contract balance to the winner
        betAmountLocked = false; // Unlock the bet amount for the next round
        candidates = new address payable ; // Reset candidates for the next game
    }
}
