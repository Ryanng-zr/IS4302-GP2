// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Post {
    struct PostData {
        uint id;
        address author;
        string content;
        uint timestamp;
    }

    PostData[] public posts;
    uint public nextPostId;

    function createPost(string memory _content) public {
        posts.push(PostData(nextPostId, msg.sender, _content, block.timestamp));
        nextPostId++;
    }

    function getPost(uint _postId) public view returns (PostData memory) {
        require(_postId < posts.length, "Post does not exist.");
        return posts[_postId];
    }

    function deletePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist.");
        require(posts[_postId].author == msg.sender, "Only the author can delete their post.");
        delete posts[_postId];
    }
}
