// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./User.sol";

contract AcceptanceVoting {
    enum VotingState {
        OPEN,
        CLOSED
    }

    struct Criterion {
        uint regularUserVotes;
        uint verifiedVerifierVotes;
    }

    User public userContract;

    address[] voters;

    mapping(address => bool) isVoter;

    // users => reportId => true if voted
    mapping(address => mapping(uint256 => bool)) hasVoted;

    mapping(uint256 => VotingState) reportVotingState;
    mapping(uint256 => uint256) reportVotingScore;

    // reportId => criteria name => vote count
    mapping(uint256 => mapping(string => Criterion)) public criteria;
    // reportId => type of voters => total number of voters
    //  option for string -> totalRegularUsers, totalVerifiedVerifiers
    mapping(uint256 => mapping(string => uint256)) votersBreakdown;
    // vote open block number
    mapping(uint => uint256) reportVotingOpenTimeframe;

    // verified for misinformation
    mapping(uint256 => bool) isApproved;

    // voting ended
    mapping(uint256 => bool) isConcluded;

    uint256 potOfMoney;

    uint256 constant VOTING_PERIOD_BLOCKS = 28800; // Approximately 48 hours (assuming 12-second block time)

    uint256 constant REGULAR_USER_VOTE_WEIGHT = 1;
    uint256 constant VERIFIER_VOTE_WEIGHT = 4;

    uint256 constant FACTUAL_ACCURACY_WEIGHT = 40;
    uint256 constant MALICIOUS_INTENT_WEIGHT = 20;
    uint256 constant HARMFUL_CONSEQUENCES_WEIGHT = 20;
    uint256 constant CONTENT_MANIPULATION_WEIGHT = 10;
    uint256 constant POLICY_VIOLATION_WEIGHT = 10;

    uint256 constant VALIDITY_THRESHOLD = 70;

    // events
    event voter_added(address user);

    event vote_open(uint256 reportId, uint256 blockNumber);
    event vote_close(uint256 reportId, uint256 blockNumber);

    event voted(
        address user,
        bool factualAccuracy,
        bool maliciousIntent,
        bool harmfulConsequences,
        bool contentManipulation,
        bool violationOfPlatformPolicies
    );

    event vote_results_accepted(
        string outcome,
        uint256 reportId,
        uint256 score
    );
    event vote_results_rejected(
        string outcome,
        uint256 reportId,
        uint256 score
    );

    event fee_distributed(
        address voter,
        uint256 val,
        uint256 contract_balance,
        uint256 acc_balance
    );

    constructor(User _userContract) {
        userContract = _userContract;
    }

    function vote(
        uint256 reportId,
        bool factualAccuracy,
        bool maliciousIntent,
        bool contentManipulation,
        bool harmfulConsequences,
        bool violationOfPlatformPolicies
    ) public payable {
        require(isVoter[msg.sender], "You are not a registered voter");
        require(
            reportVotingState[reportId] == VotingState.OPEN,
            "Applicant is not open for voting"
        );

        // Ensure that the voter has paid the fee
        require(
            msg.value >= 100000000000000,
            "Insufficient ether sent for voting fee"
        );

        // Add the fee to the potOfMoney
        potOfMoney += msg.value;

        hasVoted[msg.sender][reportId] = true;

        User.userGroup userGroup = userContract.getUserGroupByAddress(
            msg.sender
        );

        if (userGroup == User.userGroup.VERIFIER) {
            votersBreakdown[reportId]["totalVerifiedVerifiers"] += 1;
            if (factualAccuracy) {
                (criteria[reportId]["factualAccuracy"])
                    .verifiedVerifierVotes += 1;
            }

            if (maliciousIntent) {
                (criteria[reportId]["maliciousIntent"])
                    .verifiedVerifierVotes += 1;
            }

            if (contentManipulation) {
                (criteria[reportId]["contentManipulation"])
                    .verifiedVerifierVotes += 1;
            }

            if (harmfulConsequences) {
                (criteria[reportId]["harmfulConsequences"])
                    .verifiedVerifierVotes += 1;
            }

            if (violationOfPlatformPolicies) {
                (criteria[reportId]["violationOfPlatformPolicies"])
                    .verifiedVerifierVotes += 1;
            }
        } else if (userGroup == User.userGroup.GENERAL) {
            votersBreakdown[reportId]["totalRegularUsers"] += 1;
            if (factualAccuracy) {
                (criteria[reportId]["factualAccuracy"]).regularUserVotes += 1;
            }

            if (maliciousIntent) {
                (criteria[reportId]["maliciousIntent"]).regularUserVotes += 1;
            }

            if (contentManipulation) {
                (criteria[reportId]["contentManipulation"])
                    .regularUserVotes += 1;
            }

            if (harmfulConsequences) {
                (criteria[reportId]["harmfulConsequences"])
                    .regularUserVotes += 1;
            }

            if (violationOfPlatformPolicies) {
                (criteria[reportId]["violationOfPlatformPolicies"])
                    .regularUserVotes += 1;
            }
        }
    }

    function openVote(uint256 reportId) external {
        require(
            reportVotingState[reportId] == VotingState.CLOSED,
            "Applicant already undergoing voting"
        );

        reportVotingState[reportId] = VotingState.OPEN;
        reportVotingOpenTimeframe[reportId] = block.number;

        emit vote_open(reportId, block.number);
    }

    function getCriterionScore(
        string memory criterionName,
        uint256 reportId
    ) public view returns (uint) {
        Criterion memory criterion = criteria[reportId][criterionName];
        uint regularUserPercentage = (criterion.regularUserVotes * 100) /
            votersBreakdown[reportId]["totalRegularUsers"];
        uint verifiedVerifierPercentage = (criterion.verifiedVerifierVotes *
            100) / votersBreakdown[reportId]["totalVerifiedVerifiers"];
        uint score = (regularUserPercentage * 1) +
            (verifiedVerifierPercentage * 4);
        uint normalizedScore = (score * 100) / 5;
        return normalizedScore;
    }

    function calculateScore(uint256 reportId) public {
        uint overallWeightedScore;
        overallWeightedScore +=
            (getCriterionScore("factualAccuracy", reportId) *
                FACTUAL_ACCURACY_WEIGHT) /
            100;
        overallWeightedScore +=
            (getCriterionScore("maliciousIntent", reportId) *
                MALICIOUS_INTENT_WEIGHT) /
            100;
        overallWeightedScore +=
            (getCriterionScore("harmfulConsequences", reportId) *
                HARMFUL_CONSEQUENCES_WEIGHT) /
            100;
        overallWeightedScore +=
            (getCriterionScore("contentManipulation", reportId) *
                CONTENT_MANIPULATION_WEIGHT) /
            100;
        overallWeightedScore +=
            (getCriterionScore("violationOfPlatformPolicies", reportId) *
                POLICY_VIOLATION_WEIGHT) /
            100;

        reportVotingScore[reportId] = overallWeightedScore;
    }

    function closeVote(uint256 reportId) public {
        require(
            reportVotingState[reportId] == VotingState.OPEN,
            "Vote is not open"
        );
        require(
            reportVotingOpenTimeframe[reportId] + VOTING_PERIOD_BLOCKS <=
                block.number,
            "Deadline not up"
        );

        calculateScore(reportId);

        if (reportVotingScore[reportId] >= VALIDITY_THRESHOLD) {
            isApproved[reportId] = true;
            emit vote_results_accepted(
                "Accepted - Misinformation verified",
                reportId,
                reportVotingScore[reportId]
            );
        } else {
            isApproved[reportId] = false;
            emit vote_results_rejected(
                "Rejected - Misinformation not verified",
                reportId,
                reportVotingScore[reportId]
            );
        }

        isConcluded[reportId] = true;
        reportVotingState[reportId] = VotingState.CLOSED;
        distributeFee(reportId);

        emit vote_close(reportId, block.number);
    }

    function distributeFee(uint256 reportId) public payable {
        require(isConcluded[reportId] == true, "Voting has not concluded");

        uint256 numberOfVoters;

        for (uint256 i = 0; i < voters.length; i++) {
            if (hasVoted[voters[i]][reportId]) {
                numberOfVoters++;
            }
        }

        require(numberOfVoters > 0, "No voters for this report");

        uint256 reward = (((potOfMoney * 12) / 10) * 1E18) / numberOfVoters;

        for (uint256 j = 0; j < voters.length; j++) {
            if (hasVoted[voters[j]][reportId]) {
                address payable recipient = payable(voters[j]);
                recipient.transfer(reward);
                emit fee_distributed(
                    voters[j],
                    reward,
                    address(this).balance,
                    address(voters[j]).balance
                );
            }
        }
    }

    function addVoter(address user) public {
        require(isVoter[user] != true, "You are already registered");

        voters.push(user);
        isVoter[user] = true;

        emit voter_added(user);
    }

    function getVotingState(
        uint256 reportId
    ) public view returns (VotingState) {
        return reportVotingState[reportId];
    }

    function checkApproved(uint256 reportId) public view returns (bool) {
        return isApproved[reportId];
    }

    function checkConcluded(uint256 reportId) public view returns (bool) {
        return isConcluded[reportId];
    }

    function checkIfVoter(address user) public view returns (bool) {
        return isVoter[user];
    }
}
