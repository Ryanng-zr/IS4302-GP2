const AcceptanceVoting = artifacts.require("../contracts/AcceptanceVoting.sol");
const User = artifacts.require("../contracts/User.sol");
const Report = artifacts.require("../contracts/Report.sol");
const Post = artifacts.require("../contracts/Post.sol");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const BigNumber = require("bignumber.js");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("AcceptanceVoting", (accounts) => {
  let acceptanceVotingInstance;
  let userInstance;
  let postInstance;
  let reportInstance;

  before(async () => {
    userInstance = await User.deployed();
    postInstance = await Post.deployed();
    reportInstance = await Report.deployed();
    acceptanceVotingInstance = await AcceptanceVoting.deployed();
  });

  it("should add voters", async () => {
    await acceptanceVotingInstance.addVoter(accounts[1]);
    let isVoter = await acceptanceVotingInstance.checkIfVoter(accounts[1]);
    assert.equal(isVoter, true, "Voter not added successfully");

    // Attempt to add the same voter again
    await truffleAssert.fails(
      acceptanceVotingInstance.addVoter(accounts[1]),
      truffleAssert.ErrorType.REVERT,
      "You are already registered"
    );
  });

  it("should open and close voting", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    let reportId = await reportInstance.addReport(
      0,
      "This is a test justification",
      { from: accounts[0], value: oneEth.dividedBy(10000) }
    );

    await acceptanceVotingInstance.openVote(reportId);

    let votingState = await acceptanceVotingInstance.getVotingState(reportId);
    assert.equal(votingState, 0, "Voting did not open successfully");

    // Attempt to open voting again
    await truffleAssert.fails(
      acceptanceVotingInstance.openVote(reportId),
      truffleAssert.ErrorType.REVERT,
      "Applicant already undergoing voting"
    );

    // Fast forward time to close the vote
    await truffleAssert.passes(acceptanceVotingInstance.closeVote(reportId));

    // Check if the vote has been concluded
    let isConcluded = await acceptanceVotingInstance.checkConcluded(reportId);
    assert.equal(isConcluded, true, "Voting did not close successfully");
  });

  it("should allow voting", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    let reportId = await reportInstance.addReport(
      0,
      "This is a test justification",
      { from: accounts[0], value: oneEth.dividedBy(10000) }
    );

    await acceptanceVotingInstance.addVoter(accounts[2]);

    await acceptanceVotingInstance.vote(
      reportId,
      true, // factualAccuracy
      false, // maliciousIntent
      false, // contentManipulation
      false, // harmfulConsequences
      false, // violationOfPlatformPolicies
      { from: accounts[1], value: oneEth.dividedBy(100000) }
    );

    // Attempt to vote with an unregistered user
    await truffleAssert.fails(
      acceptanceVotingInstance.vote(
        reportId,
        true,
        false,
        false,
        false,
        false,
        { from: accounts[3], value: oneEth.dividedBy(100000) }
      ),
      truffleAssert.ErrorType.REVERT,
      "You are not a registered voter"
    );

    // Retrieve voting breakdown for the report
    let votingBreakdown = await acceptanceVotingInstance.votersBreakdown(
      reportId
    );
    assert.equal(
      votingBreakdown.totalRegularUsers,
      1,
      "Regular user vote count not updated"
    );
  });
});
