const User = artifacts.require("../contracts/User.sol");
const ERC20 = artifacts.require("../contracts/ERC20.sol");

contract("User", (accounts) => {
  let userInstance;
  let tokenInstance;

  before(async () => {
    tokenInstance = await ERC20.new("TestToken", "TT", { from: accounts[0] });
    userInstance = await User.new(tokenInstance.address);
  });

  it("should register a user", async () => {
    await userInstance.registerUser("alice", "alice@example.com", { from: accounts[1] });
    const userProfile = await userInstance.getUserProfile(accounts[1]);
    assert.equal(userProfile.username, "alice", "The username should be 'alice'.");
    assert.equal(userProfile.email, "alice@example.com", "The email should be 'alice@example.com'.");
  });

  it("should not allow to register a user twice", async () => {
    try {
      await userInstance.registerUser("alice2", "alice2@example.com", { from: accounts[1] });
      assert.fail("The transaction should have thrown an error.");
    } catch (err) {
      assert.include(err.message, "User already registered", "The error should contain 'User already registered'");
    }
  });

  it("should update the email of an existing user", async () => {
    await userInstance.updateUserEmail("alice@newdomain.com", { from: accounts[1] });
    const userProfile = await userInstance.getUserProfile(accounts[1]);
    assert.equal(userProfile.email, "alice@newdomain.com", "The email should have been updated to 'alice@newdomain.com'.");
  });

  it("should not update the email of a non-registered user", async () => {
    try {
      await userInstance.updateUserEmail("bob@newdomain.com", { from: accounts[2] });
      assert.fail("The transaction should have thrown an error.");
    } catch (err) {
      assert.include(err.message, "User not registered", "The error should contain 'User not registered'");
    }
  });

  // Add more tests here if necessary
});

