// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Post.sol";

contract Report {
    enum reportStatus { INVALID, VOTING_IN_PROGRESS, VERIFIED }

    struct report {
        uint256 postId;
        string justification;
        reportStatus status;
        uint256 reportedAt;
        address reporter;
    }

    Post postContract;

    constructor(Post postContractAddress) {
        postContract = postContractAddress;
    }

    uint256 public numReports = 0;

    mapping(uint256 => report) public reports;

    event ReportAdded(uint256 reportId, uint256 postId, address reporter);
    event ReportUpdated(uint256 reportId, reportStatus status);

    modifier validReportId(uint256 reportId) {
        require(reportId < numReports, "The report id is not valid");
        _;
    }

    modifier validPostId(uint256 postId) {
        require(postId < postContract.numPosts(), "The post id is not valid");
        _;
    }

    function addReport(uint256 postId, string memory justification) public validPostId(postId) returns (uint256 reportId) {
        require(bytes(justification).length > 0, "Report justification cannot be empty");
        
        report memory newReport = report(
            postId,
            justification,
            reportStatus.VOTING_IN_PROGRESS,
            block.timestamp,
            msg.sender
        );
  
        uint256 newReportId = numReports;
        reports[newReportId] = newReport;
        numReports++;

        emit ReportAdded(newReportId, postId, msg.sender);

        return newReportId;
    }
    
    function updateReport(uint256 reportId, reportStatus newStatus) public validReportId(reportId) {
        reports[reportId].status = newStatus;
        emit ReportUpdated(reportId, newStatus);
    }

    /* Getter Functions */

    function getReportPostId(uint256 reportId) public view validReportId(reportId) returns (uint256) {
        return reports[reportId].postId;
    }

    function getReportJustification(uint256 reportId) public view validReportId(reportId) returns (string memory) {
        return reports[reportId].justification;
    }

    function getReportReportedAt(uint256 reportId) public view validReportId(reportId) returns (uint256) {
        return reports[reportId].reportedAt;
    }

    function getReportReporter(uint256 reportId) public view validReportId(reportId) returns (address) {
        return reports[reportId].reporter;
    }
}
