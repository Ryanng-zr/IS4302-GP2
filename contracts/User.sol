// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract User {
    address public owner;
    uint256 public numUsers = 0;
    
    enum userGroup {
        GENERAL,
        VERIFIER,
        DELETED
    }

    struct user {
        string name;
        string email;
        userGroup group;
        address owner;
    }

    mapping(uint256 => user) public users;

    event UserAdded(uint256 userAddress, string name, string email);
    event UserUpdated(uint256 userId, userGroup group);
    event UserDeleted(string name, string email);
    
    modifier ownerOnly() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    modifier validUserId(uint256 userId) {
        require(userId < numUsers, "The user id is not valid");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
    }

    function addUser(string memory name, string memory email) public returns (uint256) {
        require(bytes(name).length > 0, "User name cannot be empty");
        require(bytes(email).length > 0, "User email cannot be empty");

        uint256 userId = numUsers;
        users[userId] = user(name, email, userGroup.GENERAL, msg.sender); 
        numUsers++;
        
        emit UserAdded(userId, name, email);

        return userId;
    }

    function updateUserType(uint256 userId, userGroup group) public ownerOnly validUserId(userId) {
        users[userId].group = group;
        emit UserUpdated(userId, group);
    }

    function deleteUser(uint256 userId) public ownerOnly validUserId(userId) {
        user storage userToBeDeleted = users[userId];

        require(userToBeDeleted.group != userGroup.DELETED, "User has already been deleted");
        
        userToBeDeleted.group = userGroup.DELETED;

        emit UserDeleted(userToBeDeleted.name, userToBeDeleted.email);
    }
}
