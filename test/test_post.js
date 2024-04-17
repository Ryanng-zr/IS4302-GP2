const truffleAssert = require("truffle-assertions");
const assert = require("assert");

const Post = artifacts.require("../contracts/Post.sol");

contract("Post Test", (accounts) => {
  let postInstance;

  before(async () => {
    postInstance = await Post.deployed();
  });

  it("Add Post", async () => {
    let addPost = await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    assert.notStrictEqual(addPost, undefined, "Failed to add post");
    truffleAssert.eventEmitted(addPost, "PostAdded");

    let postTitle = await postInstance.getPostTitle(0);
    assert.strictEqual(
      postTitle,
      "Test Title",
      "Post created with incorrect title"
    );
    let postContent = await postInstance.getPostContent(0);
    assert.strictEqual(
      postContent,
      "Test content",
      "Post created with incorrect content"
    );
  });

  it("Incorrect Add Post", async () => {
    truffleAssert.reverts(
      postInstance.addPost("", "Test content", { from: accounts[0] }),
      "Post title cannot be empty"
    );

    truffleAssert.reverts(
      postInstance.addPost("Test title", "", { from: accounts[0] }),
      "Post content cannot be empty"
    );
  });

  it("View Post By Id", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    let postView = await postInstance.viewPostById(0, { from: accounts[0] });

    let lines = postView.split("\n");
    let id = lines[0];
    let title = lines[1];
    let content = lines[2];
    let status = lines[3];

    assert.strictEqual(id, "ID: 0");

    assert.strictEqual(title, "Title: Test Title");

    assert.strictEqual(content, "Content: Test content");

    assert.strictEqual(status, "Status: VOTING IN PROGRESS");
  });

  it("View Post By User Address", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[1],
    });

    let postView = await postInstance.viewPostsByUserAddress(accounts[1], { from: accounts[1] });

    let lines = postView.split("\n");
    let id = lines[0];
    let title = lines[1];
    let content = lines[2];
    let status = lines[3];

    assert.strictEqual(id, "ID: 2");

    assert.strictEqual(title, "Title: Test Title");

    assert.strictEqual(content, "Content: Test content");

    assert.strictEqual(status, "Status: VOTING IN PROGRESS");
  });

  it("Delete Post", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    let deletePost = await postInstance.deletePost(0, { from: accounts[0] });
    truffleAssert.eventEmitted(deletePost, "PostDeleted");

    truffleAssert.reverts(
      postInstance.deletePost(0, { from: accounts[0] }),
      "Post has already been deleted"
    );
  });
});
