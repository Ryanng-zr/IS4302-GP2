const MisinformationReport = artifacts.require("../contracts/MisinformationReport.sol");
const Post = artifacts.require("../contracts/Post.sol");

contract("MisinformationReport", accounts => {
    const [reporter, verifier] = accounts;
    let postInstance;
    let misinformationReportInstance;

    before(async () => {
        postInstance = await Post.deployed();
        misinformationReportInstance = await MisinformationReport.deployed(postInstance.address);

        await postInstance.createPost("Test Post Title", "Test Post Content", { from: reporter });
    });

    it("should allow adding a misinformation report", async () => {
        let result = await misinformationReportInstance.addMisinformationReport(0, "Justification for the report", { from: reporter });
        
        assert.equal(result.logs[0].event, "MisinformationReportCreated", "MisinformationReportCreated event should be emitted.");
        let report = await misinformationReportInstance.reports(0);
        assert.equal(report.justification, "Justification for the report", "The justification should match the input.");
    });

    it("should delete a misinformation report", async () => {
        let result = await misinformationReportInstance.addMisinformationReport(0, "Justification for the report", { from: reporter });
        let reportId = result.logs[0].args.reportId.toNumber();
        
        await misinformationReportInstance.deleteMisinformationReport(reportId, { from: reporter });

        let deletedReport = await misinformationReportInstance.reports(reportId);

        assert.equal(deletedReport.reportId, 0, "Report ID should be 0 after deletion.");
        assert.equal(deletedReport.postId, 0, "Post ID should be 0 after deletion.");
        assert.equal(deletedReport.reporter, 0x0, "Reporter address should be 0x0 after deletion.");
        assert.equal(deletedReport.justification, "", "Justification should be empty after deletion.");
        assert.equal(deletedReport.timestamp, 0, "Timestamp should be 0 after deletion.");
        assert.equal(deletedReport.status, 0, "Status should be 0 after deletion.");
        assert.equal(deletedReport.verifier, 0x0, "Verifier address should be 0x0 after deletion.");
    });

    it("should update a misinformation report", async () => {
        let result = await misinformationReportInstance.addMisinformationReport(0, "Sample report", { from: reporter });
        let reportId = result.logs[0].args.reportId.toNumber();

        let report = await misinformationReportInstance.reports(reportId);
        assert.equal(report.status, 1, "Report should be in VOTING_IN_PROGRESS status.");

        await misinformationReportInstance.updateMisinformationReport(reportId, true, verifier, { from: verifier });

        let updatedReport = await misinformationReportInstance.reports(reportId);

        assert.equal(updatedReport.status, 2, "Report status should be VERIFIED.");
    });
});

