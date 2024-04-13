const MisinformationReport = artifacts.require("../contracts/MisinformationReport.sol");
const Post = artifacts.require("../contracts/Post.sol");

contract("MisinformationReport", accounts => {
    const [reporter, verifier] = accounts;
    let postInstance;
    let misinformationReportInstance;

    before(async () => {
        postInstance = await Post.deployed();
        misinformationReportInstance = await MisinformationReport.deployed(postInstance.address);
    });

    it("should allow adding a misinformation report", async () => {
        // Create a dummy post first
        await postInstance.createPost("Test Post Title", "Test Post Content", { from: reporter });
        // Report the post as misinformation
        let result = await misinformationReportInstance.addMisinformationReport(0, "Justification for the report", { from: reporter });
        
        // Check for event emission
        assert.equal(result.logs[0].event, "MisinformationReportCreated", "MisinformationReportCreated event should be emitted.");
        // Check the report details
        let report = await misinformationReportInstance.reports(0);
        assert.equal(report.justification, "Justification for the report", "The justification should match the input.");
    });

    it("should delete a misinformation report", async () => {
        // Logic to create a report first
        let result = await misinformationReportInstance.addMisinformationReport(0, "Justification for the report", { from: reporter });
        let reportId = result.logs[0].args.reportId.toNumber();
        
        // Logic to delete the report
        await misinformationReportInstance.deleteMisinformationReport(reportId, { from: reporter });
        
        // Assertions to ensure the report is deleted
        // This will need to be checked by trying to access the report and expecting a failure
        // Since Solidity does not have a native "exists" check for deleted array elements, the logic might involve checking for default values or using a mapping
    });

    // it("should resolve a misinformation report and pay a fee", async () => {
    //     // Logic to create a post and report first
    //     let result = await misinformationReportInstance.addMisinformationReport(0, "Justification for the report", { from: reporter });
    //     let reportId = result.logs[0].args.reportId.toNumber();

    //     // Ensure the contract has enough ETH if needed
    //     // Send ETH to the contract balance if required by the resolution logic

    //     // Resolve the report
    //     try {
    //         // Include { value: ... } if the contract needs to send ETH
    //         const resolutionTx = await misinformationReportInstance.resolveMisinformationReport(reportId, true, verifier, { from: reporter });
    //         // Check events emitted by the resolution transaction
    //     } catch (error) {
    //         assert.fail("Transaction should not revert: " + error.message);
    //     }
    // });
    
    
    
});

