const Post = artifacts.require("Post");
const User = artifacts.require("User");
const MisinformationReport = artifacts.require("MisinformationReport");

module.exports = function(deployer) {
  deployer.deploy(Post)
    .then(() => deployer.deploy(User))
    .then(() => deployer.deploy(MisinformationReport, Post.address));
};
