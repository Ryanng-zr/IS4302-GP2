// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Post {
    enum VerificationStatus { INVALID, VOTING_IN_PROGRESS, VERIFIED } // Added enum to match the ERD

    struct PostStruct {
        uint256 id;
        string title;
        string content;
        uint256 createdAt;
        address createdBy;
        VerificationStatus status;
    }

    PostStruct[] public posts;
    uint256 public nextPostId;

    event createPostEvent(uint256 indexed postId);
    event deletePostEvent(uint256 indexed postId);

    function createPost(string memory _title, string memory _content) public {
        PostStruct memory newPost = PostStruct({
            id: nextPostId,
            title: _title,
            content: _content,
            createdAt: block.timestamp,
            createdBy: msg.sender,
            status: VerificationStatus.VOTING_IN_PROGRESS
        });

        posts.push(newPost);
        emit createPostEvent(nextPostId);
        nextPostId++;
    }

    function getPost(uint256 _postId) public view returns (PostStruct memory) {
        require(_postId < posts.length, "Post does not exist.");
        return posts[_postId];
    }

    function deletePost(uint256 _postId) public {
        require(_postId < posts.length, "Post does not exist.");
        require(posts[_postId].createdBy == msg.sender, "Only the author can delete their post.");

        emit deletePostEvent(_postId);
        delete posts[_postId];
    }
}
