// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract User {
    // Define the user structure according to the diagram
    struct UserStruct {
        string name;
        string email;
        bool voter;
    }

    // A mapping to keep track of users by their Ethereum address
    mapping(address => UserStruct) public users;

    // An owner address variable for permissioned function calls
    address public owner;

    // A counter to keep track of the number of users
    uint256 public numUsers;

    // Events for user addition, update, and deletion
    event createUserEvent(uint256 indexed userId);
    event updateUserEvent(uint256 indexed userId);
    event deleteUserEvent(uint256 indexed userId);

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
    }

    // Function to add a new user
    function addUser(string memory _name, string memory _email) public returns (uint256) {
        require(msg.sender == owner, "Only the owner can add users.");
        numUsers++; // Increment the counter for the user ID
        users[msg.sender] = UserStruct(_name, _email, false); // Set the voter status to false by default
        emit createUserEvent(numUsers);
        return numUsers;
    }

    // Function to update an existing user's email
    function updateUser(uint256 _userId, string memory _newEmail) public {
        require(msg.sender == owner, "Only the owner can update users.");
        require(_userId <= numUsers && _userId > 0, "Invalid user ID.");
        UserStruct storage user = users[msg.sender];
        user.email = _newEmail;
        emit updateUserEvent(_userId);
    }

    // Function to delete a user
    function deleteUser(uint256 _userId) public {
        require(msg.sender == owner, "Only the owner can delete users.");
        require(_userId <= numUsers && _userId > 0, "Invalid user ID.");
        delete users[msg.sender];
        emit deleteUserEvent(_userId);
    }

    // Function to set a user's voter status
    function setUserVoterStatus(uint256 _userId, bool _voterStatus) public {
        require(msg.sender == owner, "Only the owner can update the voter status.");
        require(_userId <= numUsers && _userId > 0, "Invalid user ID.");
        UserStruct storage user = users[msg.sender];
        user.voter = _voterStatus;
    }

    function checkVoterStatus(address userAddress) public view returns (bool) {
        return users[userAddress].voter;
    }
}
