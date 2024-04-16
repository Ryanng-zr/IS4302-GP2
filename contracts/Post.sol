// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Post {
    enum postStatus { VOTING_IN_PROGRESS, INVALID, VERIFIED, DELETED }

    struct post {
        string title;
        string content;
        postStatus status;
        uint256 createdAt;
        address createdBy;
    }

    uint256 public numPosts = 0;

    mapping(uint256 => post) public posts;

    event PostAdded(uint256 postId, address createdBy, string title);
    event PostDeleted(string title, string content);

    modifier validPostId(uint256 postId) {
        require(postId < numPosts, "The post id is not valid");
        _;
    }

    function addPost(string memory title, string memory content) public returns (uint256 postId) {
        require(bytes(title).length > 0, "Post title cannot be empty");
        require(bytes(content).length > 0, "Post content cannot be empty");

        post memory newPost = post(
            title,
            content,
            postStatus.VOTING_IN_PROGRESS,
            block.timestamp,
            msg.sender
        );

        uint256 newPostId = numPosts;
        posts[newPostId] = newPost;
        numPosts++;

        // add logic for verification voting
        
        emit PostAdded(newPostId, msg.sender, title);

        return newPostId;
    }

    function viewAllPosts() public view returns (string memory _posts) {
        string[] memory allPosts = new string[](numPosts);

        for (uint256 i = 0; i < numPosts; i++) {
            allPosts[i] = encodePostToString(i);
        }

        _posts = concat(allPosts);
    }

    function viewPostById(uint256 postId) public view validPostId(postId) returns (string memory _post) {
        _post = encodePostToString(postId);
    }

    function viewPostsByUserAddress(address userAddress) public view returns (string memory _posts) {
        string[] memory userPosts = new string[](numPosts);
        uint256 userPostCount = 0;

        for (uint256 i = 0; i < numPosts; i++) {
            if (posts[i].createdBy == userAddress) {
                userPosts[userPostCount] = encodePostToString(i);
                userPostCount++;
            }
        
        _posts = concat(userPosts);
    }

    return concat(userPosts);    }

    function deletePost(uint256 postId) public validPostId(postId) {
        post storage postToBeDeleted = posts[postId];

        require(postToBeDeleted.status != postStatus.DELETED, "Post has already been deleted");

        postToBeDeleted.status = postStatus.DELETED;

        emit PostDeleted(postToBeDeleted.title, postToBeDeleted.content);
    }

    /* Getter Functions */

    function getPostTitle(uint256 postId) public view validPostId(postId) returns (string memory) {
        return posts[postId].title;
    }

    function getPostContent(uint256 postId) public view validPostId(postId) returns (string memory) {
        return posts[postId].content;
    }

    function getPostCreatedAt(uint256 postId) public view validPostId(postId) returns (uint256) {
        return posts[postId].createdAt;
    }

    function getPostCreatedBy(uint256 postId) public view validPostId(postId) returns (address) {
        return posts[postId].createdBy;
    }

    /* Helper Functions */

    /**
        @dev Concat an array of strings into a string
        @param words The array of strings to concat
    */
    function concat(string[] memory words) private pure returns (string memory) {
        bytes memory output;
        for (uint256 i = 0; i < words.length; i++) {
        output = abi.encodePacked(output, words[i]);
        }
        return string(output);
    }

    /**
        @dev Encode a credential into a formatted string
        @param postId The id of the credential to encode
    */
    function encodePostToString(uint256 postId) private view returns (string memory) {
        post memory p = posts[postId];

        return string(
            abi.encodePacked(
                "ID: ",
                uint256ToString(postId),
                "\n",
                "Title: ",
                p.title,
                "\n",
                "Content: ",
                p.content,
                "\n",
                "Status: ",
                postStatusToString(p.status),
                "\n",
                "Created At: ",
                uint256ToString(p.createdAt),
                "\n",
                "Created By: ",
                addressToString(p.createdBy),
                "\n"
            )
        );
    }
    
    /**
        @dev Convert uint256 into string
        @param _i uint256 to convert
    */
    function uint256ToString(uint256 _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length;
        
        while (_i != 0) {
            k = k - 1;
            uint8 temp = uint8(48 + (_i % 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }

        return string(bstr);
    }

    /**
        @dev Convert address into string
        @param _address addresss to convert
    */
    function addressToString(
        address _address
    ) private pure returns (string memory) {
        bytes32 value = keccak256(abi.encodePacked(_address));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }

    /**
        @dev Convert credentialState into string
        @param _status credentialState to convert
    */
    function postStatusToString(
        postStatus _status
    ) private pure returns (string memory state) {
        if (_status == postStatus.VOTING_IN_PROGRESS) {
            return "VOTING IN PROGRESS";
        } else if (_status == postStatus.INVALID) {
            return "INVALID";
        } else if (_status == postStatus.VERIFIED) {
            return "VERIFIED";
        } else if (_status == postStatus.DELETED) {
            return "DELETED";
        }
    }
}
