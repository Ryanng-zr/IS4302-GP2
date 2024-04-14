const Post = artifacts.require('Post');
const User = artifacts.require('User');
const MisinformationReport = artifacts.require('MisinformationReport');
const Token = artifacts.require('Token');
const AcceptanceVoting = artifacts.require('AcceptanceVoting');

module.exports = function (deployer) {
  deployer
    .deploy(Post)
    .then(() => deployer.deploy(User))
    .then(() => deployer.deploy(MisinformationReport, Post.address))
    .then(() => deployer.deploy(Token))
    .then(() => deployer.deploy(AcceptanceVoting, User.address, 48));
};
