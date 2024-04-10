// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Post.sol";

contract MisinformationReport {
    // The VerificationStatus enum based on the ERD
    enum VerificationStatusEnum { INVALID, VOTING_IN_PROGRESS, VERIFIED }

    // The Report struct based on the ERD
    struct MisinformationReportStruct {
        uint256 reportId;
        uint256 postId;
        address reporter;
        string justification;
        uint256 timestamp;
        VerificationStatusEnum status;
        address verifier; // Address of the user who verifies the report
    }

    Post public postContract;
    MisinformationReportStruct[] public reports;
    uint256 public nextReportId;

    // Events as per the ERD
    event MisinformationReportCreated(uint256 indexed reportId, uint256 indexed postId, address reporter);
    event MisinformationReportResolved(uint256 indexed reportId, bool isValid);
    event MisinformationReportUpdated(uint256 indexed reportId);
    event FeePaid(address indexed verifier, uint256 amount);
    event MisinformationReportDeleted(uint256 indexed reportId);

    constructor(address _postContractAddress) {
        postContract = Post(_postContractAddress);
    }

    function addMisinformationReport(uint256 _postId, string memory _justification) public {
        // Fetch the post using the post contract to make sure it exists
        Post.PostStruct memory postData = postContract.getPost(_postId);
        require(postData.createdBy != address(0), "Post does not exist.");

        // Create and store the report
        MisinformationReportStruct memory newReport = MisinformationReportStruct({
            reportId: nextReportId,
            postId: _postId,
            reporter: msg.sender,
            justification: _justification,
            timestamp: block.timestamp,
            status: VerificationStatusEnum.VOTING_IN_PROGRESS,
            verifier: address(0) // Initially there's no verifier
        });

        reports.push(newReport);
        emit MisinformationReportCreated(nextReportId, _postId, msg.sender);
        nextReportId++;
    }

    // Other functions like deleteMisinformationReport, updateMisinformationReport, and payFee would go here

    // Example of a function to resolve a report and pay a fee to the verifier
    function resolveMisinformationReport(uint256 _reportId, bool _isValid, address _verifier) public {
        require(_reportId < reports.length, "Report does not exist.");
        MisinformationReportStruct storage report = reports[_reportId];
        require(report.status == VerificationStatusEnum.VOTING_IN_PROGRESS, "Report is not in the correct state.");

        // Set the report as verified or invalid based on votes
        report.status = _isValid ? VerificationStatusEnum.VERIFIED : VerificationStatusEnum.INVALID;
        report.verifier = _verifier;

        // Pay the fee to the verifier
        uint256 feeAmount = calculateFee(); // You would need to implement this function
        payable(_verifier).transfer(feeAmount);

        emit MisinformationReportResolved(_reportId, _isValid);
        emit FeePaid(_verifier, feeAmount);
    }

    // If _reportId is not used and no state is read, you can declare the function as pure and remove the parameter
    function calculateFee() private pure returns (uint256) {
        // Placeholder calculation for the fee
        return 1 ether; // This is just an example. Adjust as necessary.
    }

    function deleteMisinformationReport(uint256 _reportId) public {
        require(_reportId < reports.length, "Report does not exist.");
        // Additional checks for authorization, if needed
        delete reports[_reportId];
        emit MisinformationReportDeleted(_reportId);
    }

}
