const Post = artifacts.require("../contracts/Post.sol");

contract("Post", accounts => {
    const [author] = accounts;
    let postInstance;

    before(async () => {
        postInstance = await Post.deployed();
    });

    it("should create a post and emit an event", async () => {
        let title = "Sample Title";
        let content = "This is a sample content for testing purposes.";
        let result = await postInstance.createPost(title, content, { from: author });
        
        // Check for event emission
        assert.equal(result.logs[0].event, "createPostEvent", "createPostEvent event should be emitted.");
        
        // Check that the post has been created with correct details
        let post = await postInstance.getPost(0);
        assert.equal(post.title, title, "The title of the post should match the input.");
        assert.equal(post.content, content, "The content of the post should match the input.");
        assert.equal(post.createdBy, author, "The author of the post should match the sender.");
    });

    it("should retrieve a post", async () => {
        let post = await postInstance.getPost(0);
        assert.equal(post.id, 0, "The id of the post should be 0.");
    });


    it("should delete a post and emit an event", async () => {
        // Create a post
        let createResult = await postInstance.createPost("Test Post", "Test content", { from: author });
        const postId = createResult.logs[0].args.postId.toNumber();
    
        // Delete the post
        let deleteResult = await postInstance.deletePost(postId, { from: author });
        assert.equal(deleteResult.logs[0].event, "deletePostEvent", "deletePostEvent event should be emitted.");
    
        // Attempt to retrieve the deleted post, expecting a revert
        try {
            await postInstance.getPost(postId);
            assert.fail("Expected a revert but did not get one.");
        } catch (error) {
            assert.include(error.message, "revert", "Expected a revert error containing 'revert'");
        }
    });
    
    
    
      
});

