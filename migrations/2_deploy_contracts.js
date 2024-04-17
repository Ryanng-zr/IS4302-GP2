const Post = artifacts.require("Post");
const User = artifacts.require("User");
const Report = artifacts.require("Report");
const Token = artifacts.require('Token');
const AcceptanceVoting = artifacts.require('AcceptanceVoting');

module.exports = function (deployer) {
  deployer
    .deploy(Post)
    .then(() => deployer.deploy(User))
    .then(() => deployer.deploy(Report, Post.address));
    .then(() => deployer.deploy(Token))
    .then(() => deployer.deploy(AcceptanceVoting, User.address, 48));
};
