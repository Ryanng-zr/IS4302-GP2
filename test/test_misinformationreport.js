const MisinformationReport = artifacts.require("../contracts/MisinformationReport.sol");
const Post = artifacts.require("../contracts/Post.sol");

contract("MisinformationReport", (accounts) => {
    let misinformationReportInstance;
    let postInstance;

    before(async () => {
        postInstance = await Post.new();
        misinformationReportInstance = await MisinformationReport.new(postInstance.address);
        await postInstance.createPost("This is a test post", { from: accounts[0] });
    });

    it("should report misinformation on a post", async () => {
        await misinformationReportInstance.reportMisinformation(0, "Fake news content", { from: accounts[1] });
        const report = await misinformationReportInstance.getReport(0);
        assert.equal(report.justification, "Fake news content", "The justification should match the input.");
        assert.equal(report.isResolved, false, "The report should not be resolved initially.");
    });

    it("should allow users to vote on a report", async () => {
        await misinformationReportInstance.voteOnReport(0, true, { from: accounts[2] });
        await misinformationReportInstance.voteOnReport(0, false, { from: accounts[3] });
      
        // Assuming that these functions have been added to the MisinformationReport contract
        const validVotesCount = await misinformationReportInstance.getValidVotesCount(0);
        const invalidVotesCount = await misinformationReportInstance.getInvalidVotesCount(0);
      
        assert.equal(validVotesCount.toNumber(), 1, "There should be one valid vote.");
        assert.equal(invalidVotesCount.toNumber(), 1, "There should be one invalid vote.");
    });
  

    it("should resolve a report based on votes", async () => {
        // Voting again to ensure the valid votes win
        await misinformationReportInstance.voteOnReport(0, true, { from: accounts[4] });
        await misinformationReportInstance.resolveReport(0, { from: accounts[0] });

        const report = await misinformationReportInstance.getReport(0);
        assert.equal(report.isResolved, true, "The report should be resolved.");
        assert.equal(report.isValid, true, "The report should be marked as valid.");
    });

    it("should not allow voting on a resolved report", async () => {
        try {
        await misinformationReportInstance.voteOnReport(0, true, { from: accounts[5] });
        assert.fail("The transaction should have thrown an error.");
        } catch (err) {
        assert.include(err.message, "Report is already resolved", "Should not be able to vote on a resolved report.");
        }
    });

    // Additional tests can be written for other scenarios as needed
});
