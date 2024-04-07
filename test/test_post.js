const Post = artifacts.require("../contracts/Post.sol");

contract("Post", (accounts) => {
    let postInstance;

    before(async () => {
        postInstance = await Post.new();
    });

    it("should create a post", async () => {
        await postInstance.createPost("Hello, World!", { from: accounts[0] });
        const post = await postInstance.getPost(0);
        assert.equal(post.content, "Hello, World!", "Post content did not match the input.");
    });

    it("should retrieve a post", async () => {
        const post = await postInstance.getPost(0);
        
        // Convert BigNumber to number if necessary, otherwise just use the value directly
        const postId = post.id.toNumber ? post.id.toNumber() : post.id;
      
        assert.equal(postId, 0, "Post ID should be 0.");
        assert.equal(post.author, accounts[0], "Post author should match the creator's address.");
        assert.equal(post.content, "Hello, World!", "Post content did not match the input.");
        
        // Timestamp is also a BigNumber, so convert it in a similar way
        const postTimestamp = post.timestamp.toNumber ? post.timestamp.toNumber() : post.timestamp;
        assert(postTimestamp > 0, "Post timestamp should be greater than 0.");
    });
      
    it("should allow the author to delete their post", async () => {
        await postInstance.createPost("Post to delete", { from: accounts[1] });
        const postIdToDelete = 1;
        await postInstance.deletePost(postIdToDelete, { from: accounts[1] });

        // Truffle does not currently have a direct way to check for array element deletion
        // so we check that the author is set to 0x0, which indicates deletion
        const postAfterDeletion = await postInstance.getPost(postIdToDelete);
        assert.equal(postAfterDeletion.author, '0x0000000000000000000000000000000000000000', "Post should be deleted.");
    });

    it("should not allow a non-author to delete a post", async () => {
        await postInstance.createPost("Another post", { from: accounts[2] });
        const postIdToDelete = 2;

        try {
        await postInstance.deletePost(postIdToDelete, { from: accounts[3] });
        assert.fail("The transaction should have thrown an error");
        } catch (err) {
        assert.include(err.message, "Only the author can delete their post", "The error message should contain 'Only the author can delete their post'");
        }
    });
});