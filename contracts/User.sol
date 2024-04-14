// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract User {
    struct UserStruct {
        string name;
        string email;
        bool voter;
    }

    mapping(address => UserStruct) public users;

    address public owner;

    uint256 public numUsers;

    event createUserEvent(uint256 indexed userId);
    event updateUserEvent(uint256 indexed userId);
    event deleteUserEvent(uint256 indexed userId);

    constructor() {
        owner = msg.sender; 
    }

    function addUser(string memory _name, string memory _email) public returns (uint256) {
        require(msg.sender == owner, "Only the owner can add users.");
        numUsers++; 
        users[msg.sender] = UserStruct(_name, _email, false); 
        emit createUserEvent(numUsers);
        return numUsers;
    }

    function updateUser(uint256 _userId, string memory _newEmail) public {
        require(msg.sender == owner, "Only the owner can update users.");
        require(_userId <= numUsers && _userId > 0, "Invalid user ID.");
        UserStruct storage user = users[msg.sender];
        user.email = _newEmail;
        emit updateUserEvent(_userId);
    }

    function deleteUser(uint256 _userId) public {
        require(msg.sender == owner, "Only the owner can delete users.");
        require(_userId <= numUsers && _userId > 0, "Invalid user ID.");
        delete users[msg.sender];
        emit deleteUserEvent(_userId);
    }

    function checkVoterStatus(address userAddress) public view returns (bool) {
        return users[userAddress].voter;
    }
}
