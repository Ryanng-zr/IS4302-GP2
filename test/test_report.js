const truffleAssert = require("truffle-assertions");
const BigNumber = require("bignumber.js");
var assert = require("assert");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

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
      { from: accounts[0], value: oneEth.dividedBy(10000) }
    );

    assert.notStrictEqual(addReport, undefined, "Failed to add report");
    truffleAssert.eventEmitted(addReport, "ReportAdded");
  });

  it("Incorrect Add Report", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    truffleAssert.reverts(
      reportInstance.addReport(0, "This is a test justification", {
        from: accounts[0],
        value: oneEth.dividedBy(1000000),
      }),
      "Insufficient ether sent for adding report"
    );

    truffleAssert.reverts(
      reportInstance.addReport(0, "", {
        from: accounts[0],
        value: oneEth.dividedBy(10000),
      }),
      "Report justification cannot be empty"
    );
  });

  it("Update Report", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    await reportInstance.addReport(0, "This is a test justification", {
      from: accounts[0],
      value: oneEth.dividedBy(10000),
    });

    let updateReport = await reportInstance.updateReport(0, 1, {
      from: accounts[0],
    });

    truffleAssert.eventEmitted(updateReport, "ReportUpdated");
  });

  it("Delete Report", async () => {
    await postInstance.addPost("Test Title", "Test content", {
      from: accounts[0],
    });

    await reportInstance.addReport(0, "This is a test justification", {
      from: accounts[0],
      value: oneEth.dividedBy(10000),
    });

    let deleteReport = await reportInstance.deleteReport(0, {
      from: accounts[0],
    });

    truffleAssert.eventEmitted(deleteReport, "ReportDeleted");

    truffleAssert.reverts(
      reportInstance.deleteReport(0, { from: accounts[0] }),
      "Report has already been deleted"
    );
  });
});
