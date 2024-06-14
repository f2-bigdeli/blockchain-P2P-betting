// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contract for a peer-to-peer betting system
contract BettingContract {
    // Structure to store details of a bet
    struct Bet {
        uint256 amount;       // Amount of ether bet
        uint256 prediction;   // 0, 1, or 2 for the three possible outcomes
    }

    address payable public user1;
    address payable public user2;
    address payable public user3; // Optional third user

    uint256 public matchNumber;    // Identifier for the match
    uint256 public matchResult;    // Result of the match, set manually
    bool public betsClosed = false; // Flag to indicate if betting is closed

    // Mapping from user address to their bet details
    mapping(address => Bet) public bets;
    uint256 public constant MIN_BET_AMOUNT = 1e6; // Minimum bet amount in wei

    // Events for logging activities on the blockchain
    event BetPlaced(address user, uint256 matchNumber, uint256 amount, uint256 prediction);
    event MatchResultSet(uint256 matchNumber, uint256 result);
    event Payout(address winner, uint256 amount);

    // Constructor to initialize the contract
    constructor() {
        manager = msg.sender; // The creator of the contract is the manager
    }

    // Function for user1 to place a bet
    function placeBetUser1(uint256 _matchNumber, uint256 _prediction) external payable {
        require(!betsClosed, "Betting is closed.");
        require(msg.value >= MIN_BET_AMOUNT, "Bet amount is below the minimum.");
        require(user1 == address(0), "User1 has already placed a bet.");

        user1 = payable(msg.sender);
        matchNumber = _matchNumber;
        bets[user1] = Bet(msg.value, _prediction);

        emit BetPlaced(user1, _matchNumber, msg.value, _prediction);
    }

    // Function for user2 to place a bet
    function placeBetUser2(uint256 _prediction) external payable {
        require(!betsClosed, "Betting is closed.");
        require(msg.value >= MIN_BET_AMOUNT, "Bet amount is below the minimum.");
        require(user2 == address(0), "User2 has already placed a bet.");
        require(msg.sender != user1, "User2 cannot be User1.");

        user2 = payable(msg.sender);
        bets[user2] = Bet(msg.value, _prediction);

        emit BetPlaced(user2, matchNumber, msg.value, _prediction);
    }

    // Function for user3 to place a bet, if applicable
    function placeBetUser3(uint256 _prediction) external payable {
        require(!betsClosed, "Betting is closed.");
        require(msg.value >= MIN_BET_AMOUNT, "Bet amount is below the minimum.");
        require(user3 == address(0), "User3 has already placed a bet.");
        require(msg.sender != user1 && msg.sender != user2, "User3 cannot be User1 or User2.");

        user3 = payable(msg.sender);
        bets[user3] = Bet(msg.value, _prediction);

        emit BetPlaced(user3, matchNumber, msg.value, _prediction);
    }

    // Function to manually input the match result by a trusted party
    function inputMatchResult(uint256 _matchNumber, uint256 _result) external {
        require(_matchNumber == matchNumber, "Incorrect match number.");
        require(!betsClosed, "Betting is already closed.");
        betsClosed = true;
        matchResult = _result;

        emit MatchResultSet(_matchNumber, _result);

        // Calculate and distribute winnings
        payoutWinners();
    }

    // Internal function to handle payouts based on the match result
    function payoutWinners() internal {
        address payable[3] memory winners;
        uint256 count = 0;
        uint256 totalPot = bets[user1].amount + bets[user2].amount + (user3 != address(0) ? bets[user3].amount : 0);
        
        // Determine the winners based on the match result
        if(user1 != address(0) && bets[user1].prediction == matchResult) {
            winners[count] = user1;
            count++;
        }
        if(user2 != address(0) && bets[user2].prediction == matchResult) {
            winners[count] = user2;
            count++;
        }
        if(user3 != address(0) && bets[user3].prediction == matchResult) {
            winners[count] = user3;
            count++;
        }

        // Ensure there is at least one winner
        require(count > 0, "No winners in this match.");

        // Split the total pot equally among all winners
        uint256 payout = totalPot / count;
        for(uint256 i = 0; i < count; i++) {
            winners[i].transfer(payout);
            emit Payout(winners[i], payout);
        }
    }

    // Utility function to check the contract's balance, useful for debugging
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
