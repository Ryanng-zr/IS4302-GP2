pragma solidity ^0.8.0;

import "./User.sol";

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
    
    address[] registered;
    mapping(address => bool) isRegistered;
    mapping(address => bool) isVoter;
    mapping(address => bool) placedVotes;

    // TODO: Should we keep a record of who voted what or just the result? - to add in ERD 
    uint256 factualAccuracyScore = 0; 
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
    User user;

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
    constructor(User _user, uint256 timeFrame) {
        votingTimeframe = timeFrame;
        user = _user;
    }

    //METHODS 
    function addVoter(address userAddress) external {
        require(isRegistered[userAddress] != true, "You are already registered");
        registered.push(userAddress);
        isRegistered[userAddress]== true;
        isVoter[userAddress] = user.checkVoterStatus(userAddress);
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
        require(isRegistered[userAddress], "You are have not registered");
        require(
         placedVotes[userAddress] != true,
        "You can only vote once."
        );

        uint256 multiplier = 1; 

        if(isVoter[userAddress]) {
            multiplier = 3;
        }

        placedVotes[userAddress] = true;
        if(factualAccuracy) {
            factualAccuracyScore += multiplier;
        } 
        if(maliciousIntent) {
            maliciousIntentScore += multiplier;
        }
        if(harmfulConsequences) {
            harmfulConsequencesScore += multiplier;
        }
        if(contentManipulation) {
            contentManipulationScore += multiplier;
        }
        if(violationOfPlatformPolicies) {
            violationOfPlatformPoliciesScore += multiplier;
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
    for (uint256 i=0; i<registered.length; i++) {
        if(placedVotes[registered[i]]) {
            if(isVoter[registered[i]]) {
                noVoters += 3;
            } else {
                noVoters++;
            }
        }
    }
    uint256 weightedScore = ((maliciousIntentScore*2) + (factualAccuracyScore*4) + (harmfulConsequencesScore*2) + contentManipulationScore + violationOfPlatformPoliciesScore)/100;
    uint256 totalScore = weightedScore/noVoters;

    // TODO: add the different scenarios here

  }

}