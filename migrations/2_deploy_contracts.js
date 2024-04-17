const Post = artifacts.require("Post");
const User = artifacts.require("User");
const Report = artifacts.require("Report");

module.exports = function(deployer) {
  deployer.deploy(Post)
    .then(() => deployer.deploy(User))
    .then(() => deployer.deploy(Report, Post.address));
};
