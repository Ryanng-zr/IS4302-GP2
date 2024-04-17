const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const Report = artifacts.require("../contracts/Report.sol");
const Post = artifacts.require("../contracts/Post.sol");

contract("Report Test", (accounts) => {
  let reportInstance;

  before(async () => {
    postInstance = await Post.deployed();
    reportInstance = await Report.deployed();
  });

  it("Add Report", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    let addReport = await reportInstance.addReport(
      0,
      "This is a test justification",
      { from: accounts[0] }
    );

    assert.notStrictEqual(addReport, undefined, "Failed to add report");
    truffleAssert.eventEmitted(addReport, "ReportAdded");
  });

  it("Incorrect Add Report", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    truffleAssert.reverts(
      reportInstance.addReport(0, "", { from: accounts[0] }),
      "Report justification cannot be empty"
    );
  });

  it("Update Report", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0]
    });

    await reportInstance.addReport(0, "This is a test justification", {
      from: accounts[0]
    });

    let updateReport = await reportInstance.updateReport(0, 1, {
      from: accounts[0]
    });

    truffleAssert.eventEmitted(updateReport, "ReportUpdated");
  });
});
