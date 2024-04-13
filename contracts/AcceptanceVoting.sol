pragma solidity ^0.8.0;

contract AcceptanceVoting {

    enum VoteTypeEnum {
        APPROVE,
        REJECT
    }
    
    // TODO: not sure when to use this 
    struct Vote {
        uint256 timestamp;
        VoteTypeEnum vote;
    }
    
    address[] voters;
    mapping(address => bool) isVoter;
    mapping(address => bool) hasVoted;

    // TODO: Should we keep a record of who voted what or just the result? - to add in ERD 
    uint256 factualAccuracyScore; 
    uint256 maliciousIntentScore = 0;
    uint256 harmfulConsequencesScore = 0;
    uint256 contentManipulationScore = 0;
    uint256 violationOfPlatformPoliciesScore = 0;

    // mapping(address => bool) factualAccuracyVotes;
    // mapping(address => bool) maliciousIntentVotes;
    // mapping(address => bool) harmfulConsequencesVotes;
    // mapping(address => bool) violationOfPlatformPoliciesVotes;

    //TODO: need token? misinformation report to instantiate acceptancevoting? 
    uint256 votingTimeframe; 

    //EVENTS  
    event voter_added (address userAddress);
    event vote_open (uint256 timestamp);
    event voted (
        address userAddress,
        bool factualAccuracy,
        bool maliciousIntent,
        bool harmfulConsequences,
        bool contentManipulation,
        bool violationOfPlatformPolicies
    );
    event vote_closed (uint256 timestamp);
    event pay_fee (address userAddress, uint256 userId);
    event fee_distributed (address userAddress, uint256 distributedAmount);

    //CONSTRUCTOR 
    constructor(uint256 timeFrame) {
        votingTimeframe = timeFrame;
    }

    //METHODS 
    function addVoter(address userAddress) external {
        require(isVoter[userAddress] != true, "You are already registered as a voter");
        voters.push(userAddress);
        isVoter[userAddress]== true;
        emit voter_added(userAddress);
    }

    // TODO: should use userAddress passed in params or msg.sender ???
    function vote (
        address userAddress,
        bool factualAccuracy,
        bool maliciousIntent,
        bool contentManipulation,
        bool harmfulConsequences,
        bool violationOfPlatformPolicies
    ) public {
        require(isVoter[userAddress], "You are not a registered as a voter");
        require(
         hasVoted[userAddress] != true,
        "Each voter can only vote once."
        );

        hasVoted[userAddress] = true;
        if(factualAccuracy) {
            factualAccuracyScore++;
        } 
        if(maliciousIntent) {
            maliciousIntentScore++;
        }
        if(harmfulConsequences) {
            harmfulConsequencesScore++;
        }
        if(contentManipulation) {
            contentManipulationScore++;
        }
        if(violationOfPlatformPolicies) {
            violationOfPlatformPoliciesScore++;
        }
        //if use mapping instead - 
        // factualAccuracyVotes[userAddress] = factualAccuracy;
        // maliciousIntentVotes[userAddress] = maliciousIntent;
        // harmfulConsequencesVotes[userAddress] = harmfulConsequences;
        // violationOfPlatformPoliciesVotes[userAddress] = violationOfPlatformPolicies;

        emit voted(userAddress, factualAccuracy, maliciousIntent, harmfulConsequences, contentManipulation, violationOfPlatformPolicies);
  }

    // TODO: add requirement - need voting closed?
  function calculateResultBasedOnRegularWeightage () public {
    uint256 noVoters = 0;
    for (uint256 i=0; i<voters.length; i++) {
        if(hasVoted[voters[i]]) {
            noVoters++;
        }
    }
    uint256 weightedScore = ((maliciousIntentScore*2) + (factualAccuracyScore*4) + (harmfulConsequencesScore*2) + contentManipulationScore + violationOfPlatformPoliciesScore)/100;
    uint256 totalScore = weightedScore/noVoters;

    // TODO: add results here

  }

}