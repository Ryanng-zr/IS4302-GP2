const User = artifacts.require("../contracts/User.sol");
const ERC20 = artifacts.require("../contracts/ERC20.sol");

contract("User", accounts => {
    const [owner, user1] = accounts;
    let userInstance; 

    before(async () => {
      userInstance = await User.deployed();
    });

    it("should allow the owner to add a user", async () => {
      await userInstance.addUser("Alice", "alice@example.com", { from: owner });
      const user = await userInstance.users(owner);
      assert.equal(user.name, "Alice", "The name of the first user should be Alice.");
      assert.equal(user.email, "alice@example.com", "The email of the first user should be alice@example.com.");
      assert.equal(user.voter, false, "The voter status of the first user should be false.");
    });

    it("should allow the owner to update a user's email", async () => {
      await userInstance.updateUser(1, "alice@newdomain.com", { from: owner });
      const user = await userInstance.users(owner);
      assert.equal(user.email, "alice@newdomain.com", "The user's email should be updated to alice@newdomain.com.");
    });

    it("should not allow a non-owner to add a user", async () => {
      try {
        await userInstance.addUser("Bob", "bob@example.com", { from: user1 });
        assert.fail("The transaction should have thrown an error.");
      } catch (err) {
        assert.include(err.message, "revert", "The error message should contain 'revert'.");
      }
    });

    it("should allow the owner to delete a user", async () => {
      await userInstance.addUser("Test User", "test@email.com", { from: owner });
      await userInstance.deleteUser(1, { from: owner });
      
      let user = await userInstance.users(owner);
      assert.equal(user.name, '', "The user should be deleted.");
    });


});

