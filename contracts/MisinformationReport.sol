// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Post.sol";

contract MisinformationReport {
    struct Report {
        uint reportId;
        uint postId;
        address reporter;
        string justification;
        uint timestamp;
        bool isResolved;
        bool isValid;
    }

    Post public postContract;
    Report[] public reports;
    uint public nextReportId;

    mapping(uint => uint[]) public votesValid; // postId => [votes]
    mapping(uint => uint[]) public votesInvalid; // postId => [votes]

    constructor(address _postContractAddress) {
        postContract = Post(_postContractAddress);
    }

    function reportMisinformation(uint _postId, string memory _justification) public {
        Post.PostData memory postData = postContract.getPost(_postId);
        require(postData.author != address(0), "Post does not exist.");
        reports.push(Report(nextReportId, _postId, msg.sender, _justification, block.timestamp, false, false));
        nextReportId++;
    }

    function voteOnReport(uint _reportId, bool _isValid) public {
        require(_reportId < reports.length, "Report does not exist.");
        require(!reports[_reportId].isResolved, "Report is already resolved.");
        if (_isValid) {
            votesValid[_reportId].push(1);
        } else {
            votesInvalid[_reportId].push(1);
        }
    }

    function resolveReport(uint _reportId) public {
        require(_reportId < reports.length, "Report does not exist.");
        Report storage report = reports[_reportId];
        require(!report.isResolved, "Report is already resolved.");
        uint validVotes = votesValid[_reportId].length;
        uint invalidVotes = votesInvalid[_reportId].length;

        report.isResolved = true;
        if (validVotes > invalidVotes) {
            report.isValid = true;
        } else {
            report.isValid = false;
        }
    }

    function getReport(uint _reportId) public view returns (Report memory) {
        require(_reportId < reports.length, "Report does not exist.");
        return reports[_reportId];
    }

    function getValidVotesCount(uint _reportId) public view returns (uint) {
        return votesValid[_reportId].length;
    }

    function getInvalidVotesCount(uint _reportId) public view returns (uint) {
        return votesInvalid[_reportId].length;
    }
}
