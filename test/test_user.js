const truffleAssert = require("truffle-assertions");
const BigNumber = require("bignumber.js");
var assert = require("assert");

const User = artifacts.require("../contracts/User.sol");

contract("User Test", (accounts) => {
  let userInstance;

  before(async () => {
    userInstance = await User.deployed();
  });

  it("Add User", async () => {
    let addUser = await userInstance.addUser("Alice", "alice@example.com", {
      from: accounts[0],
    });

    assert.notStrictEqual(addUser, undefined, "Failed to add user");
    truffleAssert.eventEmitted(addUser, "UserAdded");
  });

  it("Incorrect Add User", async () => {
    truffleAssert.reverts(
      userInstance.addUser("", "alice@example.com", { from: accounts[0] }),
      "User name cannot be empty"
    );

    truffleAssert.reverts(
      userInstance.addUser("Alice", "", { from: accounts[0] }),
      "User email cannot be empty"
    );
  });

  it("Update User Group", async () => {
    await userInstance.addUser("Alice", "alice@example.com", {
      from: accounts[0],
    });

    let updateUser = await userInstance.updateUserType(0, 1, {
      from: accounts[0],
    });
    truffleAssert.eventEmitted(updateUser, "UserUpdated");
  });

  it("Delete User", async () => {
    await userInstance.addUser("Alice", "alice@example.com", {
      from: accounts[0],
    });

    let deleteUser = await userInstance.deleteUser(0, { from: accounts[0] });
    truffleAssert.eventEmitted(deleteUser, "UserDeleted");

    truffleAssert.reverts(userInstance.deleteUser(0, { from: accounts[0] }), 'User has already been deleted')
  });
});
