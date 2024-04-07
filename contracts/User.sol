// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract User {
    struct UserProfile {
        address userAddress;
        string username;
        string email;
    }

    ERC20 public token;
    mapping(address => UserProfile) public users;
    address[] public userAddresses;

    constructor(address _tokenAddress) {
        token = ERC20(_tokenAddress);
    }

    function registerUser(string memory _username, string memory _email) public {
        require(users[msg.sender].userAddress == address(0), "User already registered.");
        users[msg.sender] = UserProfile(msg.sender, _username, _email);
        userAddresses.push(msg.sender);
    }

    function updateUserEmail(string memory _newEmail) public {
        require(users[msg.sender].userAddress != address(0), "User not registered.");
        users[msg.sender].email = _newEmail;
    }

    function getUserProfile(address _userAddress) public view returns (UserProfile memory) {
        return users[_userAddress];
    }
}
