// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Betting contract for handling predictions and settling bets among participants
contract BettingContract {
    // Structure to store the amount bet and the predicted outcome
    struct Bet {
        uint256 amount;
        uint256 prediction; // 0 = team1 wins, 1 = draw, 2 = team2 wins
    }

    address payable public user1;
    address payable public user2;
    address payable public user3; // Optional third user for participation

    uint256 public user1Balance;
    uint256 public user2Balance;
    uint256 public user3Balance; // Balances of the users participating in the bet

    bool public betSettled; // Flag to indicate if the bet has been settled
    uint256 public matchNumber; // Number of the match being bet on
    uint256 public matchResult; // Result of the match after being set
    uint256 public user1Result;
    uint256 public user2Result;
    uint256 public user3Result; // Predictions by each user

    // Mappings to store user balances and bets
    mapping(address => uint256) public userBalances;
    mapping(address => uint256) public userBets;

    // Events to log actions on the blockchain
    event BetPlaced(address indexed user, uint256 amount, uint256 result);
    event BetSettled(address indexed winner, uint256 amount);

    // Constructor to initialize the contract with user balances
    constructor(
        address payable _user1,
        address payable _user2,
        address payable _user3,
        uint256 _user1InitialBalance,
        uint256 _user2InitialBalance,
        uint256 _user3InitialBalance
    ) {
        user1 = _user1;
        user2 = _user2;
        user3 = _user3;
        user1Balance = _user1InitialBalance;
        user2Balance = _user2InitialBalance;
        user3Balance = _user3InitialBalance;
        userBalances[_user1] = _user1InitialBalance;
        userBalances[_user2] = _user2InitialBalance;
        userBalances[_user3] = _user3InitialBalance;
    }

    // User1 sets the match number, bet amount, and their prediction
    function setBetAndMatch(uint256 _matchNumber, uint256 _betAmount, uint256 _result) external {
        require(!betSettled, "Bet already settled");
        require(msg.sender == user1, "Only user1 can set bet and match");
        require(_betAmount <= userBalances[user1], "Insufficient balance");
        require(_result <= 2, "Invalid result");
        require(_matchNumber > 0 && _matchNumber < 65, "Invalid match number");
        matchNumber = _matchNumber;
        userBets[user1] = _betAmount;
        user1Result = _result;
        emit BetPlaced(user1, _betAmount, _result);
    }

    // User2 sets their bet amount and prediction
    function setUser2Result(uint256 _result, uint256 _betAmount) external {
        require(msg.sender == user2, "Only user2 can set result and bet amount");
        require(!betSettled, "Bet already settled");
        require(_result <= 2, "Invalid result");
        require(_result != user1Result, "Result must differ from user1's");
        require(_betAmount <= userBalances[user2], "Insufficient balance");
        userBets[user2] = _betAmount;
        user2Result = _result;
        emit BetPlaced(user2, _betAmount, _result);
    }

    // User3 sets their bet amount and prediction
    function setUser3Result(uint256 _result, uint256 _betAmount) external {
        require(msg.sender == user3, "Only user3 can set result and bet amount");
        require(!betSettled, "Bet already settled");
        require(_result <= 2, "Invalid result");
        require(_result != user1Result && _result != user2Result, "Result must differ from other users");
        require(_betAmount <= userBalances[user3], "Insufficient balance");
        userBets[user3] = _betAmount;
        user3Result = _result;
        emit BetPlaced(user3, _betAmount, _result);
    }

    // Admin sets the final match result and triggers the settlement process
    function setMatchResult(uint256 _result) external {
        require(!betSettled, "Bet already settled");
        require(matchNumber > 0, "Match number have not set yet");
        require(_result <= 2, "Invalid result");
        matchResult = _result;
        betSettled = true;

        if (matchResult == user1Result) {
            send(userBets[user2], user2, user1);
            if (user3 != address(0)) send(userBets[user3], user3, user1);
            emit BetSettled(user1, userBets[user2] + userBets[user3]);
        } else if (matchResult == user2Result) {
            send(userBets[user1], user1, user2);
            if (user3 != address(0)) send(userBets[user3], user3, user2);
            emit BetSettled(user2, userBets[user1] + userBets[user3]);
        } else if (user3 != address(0) && matchResult == user3Result) {
            send(userBets[user1], user1, user3);
            send(userBets[user2], user2, user3);
            emit BetSettled(user3, userBets[user1] + userBets[user2]);
        }
    }

    // Internal function to transfer bet amounts between user accounts
    function send(uint256 _value, address payable _from, address payable _to) internal {
        require(userBalances[_from] >= _value, "Insufficient balance");
        userBalances[_from] -= _value;
        userBalances[_to] += _value;
    }
}
