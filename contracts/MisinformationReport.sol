// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Post.sol";

contract MisinformationReport {
    enum VerificationStatusEnum { INVALID, VOTING_IN_PROGRESS, VERIFIED }

    struct MisinformationReportStruct {
        uint256 reportId;
        uint256 postId;
        address reporter;
        string justification;
        uint256 timestamp;
        VerificationStatusEnum status;
        address verifier;
    }

    Post public postContract;
    MisinformationReportStruct[] public reports;
    uint256 public nextReportId;

    event MisinformationReportCreated(uint256 indexed reportId, uint256 indexed postId, address reporter);
    event MisinformationReportResolved(uint256 indexed reportId, bool isValid);
    event MisinformationReportUpdated(uint256 indexed reportId);
    event FeePaid(address indexed verifier, uint256 amount);
    event MisinformationReportDeleted(uint256 indexed reportId);

    constructor(address _postContractAddress) {
        postContract = Post(_postContractAddress);
    }

    function addMisinformationReport(uint256 _postId, string memory _justification) public {
        Post.PostStruct memory postData = postContract.getPost(_postId);
        require(postData.createdBy != address(0), "Post does not exist.");

        MisinformationReportStruct memory newReport = MisinformationReportStruct({
            reportId: nextReportId,
            postId: _postId,
            reporter: msg.sender,
            justification: _justification,
            timestamp: block.timestamp,
            status: VerificationStatusEnum.VOTING_IN_PROGRESS,
            verifier: address(0) 
        });

        reports.push(newReport);
        emit MisinformationReportCreated(nextReportId, _postId, msg.sender);
        nextReportId++;
    }

    function updateMisinformationReport(uint256 _reportId, bool _isValid, address _verifier) public {
        require(_reportId < reports.length, "Report does not exist.");
        MisinformationReportStruct storage report = reports[_reportId];
        require(report.status == VerificationStatusEnum.VOTING_IN_PROGRESS, "Report is not in voting stage.");

        report.status = _isValid ? VerificationStatusEnum.VERIFIED : VerificationStatusEnum.INVALID;
        report.verifier = _verifier;

        emit MisinformationReportResolved(_reportId, _isValid);
    }

    function deleteMisinformationReport(uint256 _reportId) public {
        require(_reportId < reports.length, "Report does not exist.");
        delete reports[_reportId];
        emit MisinformationReportDeleted(_reportId);
    }

}
