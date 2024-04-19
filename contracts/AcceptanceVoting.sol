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
    
    uint256[] registered;
    mapping(uint256 => bool) isRegistered;
    mapping(uint256 => bool) isVoter;
    mapping(uint256 => bool) placedVotes;

    // TODO: Should we keep a record of who voted what or just the result? - to add in ERD 
    uint256 factualAccuracyScore = 0; 
    uint256 maliciousIntentScore = 0;
    uint256 harmfulConsequencesScore = 0;
    uint256 contentManipulationScore = 0;
    uint256 violationOfPlatformPoliciesScore = 0;

    //TODO: need token? misinformation report to instantiate acceptancevoting? 
    uint256 votingTimeframe; 
    User user;

    //EVENTS  
    event voter_added (uint256 userId);
    event vote_open (uint256 timestamp);
    event voted (
        uint256 userId,
        bool factualAccuracy,
        bool maliciousIntent,
        bool harmfulConsequences,
        bool contentManipulation,
        bool violationOfPlatformPolicies
    );
    event vote_closed (uint256 timestamp);
    event pay_fee (uint256 userId, uint256 amt);
    event fee_distributed (uint256 userId, uint256 distributedAmount);

    constructor(User _user) {
        user = _user;
    }

    //METHODS 
    function addVoter(uint256 userId) external {
        require(isRegistered[userId] != true, "You are already registered");
        require(user.getNumUsers() >= userId, "User ID does not exist");
        registered.push(userId);
        isRegistered[userId] = true;
        isVoter[userId] = (user.getUserGroup(userId) == User.userGroup.VERIFIER);
        emit voter_added(userId);
    }

    // TODO: should use userAddress passed in params or msg.sender ???
    function vote (
        uint256 userId,
        bool factualAccuracy,
        bool maliciousIntent,
        bool contentManipulation,
        bool harmfulConsequences,
        bool violationOfPlatformPolicies
    ) public {
        require(isRegistered[userId], "You have not registered");
        require(
         placedVotes[userId] != true,
        "You can only vote once."
        );

        uint256 multiplier = 1; 

        if(isVoter[userId]) {
            multiplier = 3;
        }

        placedVotes[userId] = true;
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

        emit voted(userId, factualAccuracy, maliciousIntent, harmfulConsequences, contentManipulation, violationOfPlatformPolicies);
  }

    // TODO: add requirement - need voting closed?
  function calculateResultBasedOnRegularWeightage () view public returns(uint256){
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

    //NOTE: soldity dont support float - never / 100 
    uint256 weightedScore = ((maliciousIntentScore*2) + (factualAccuracyScore*4) + (harmfulConsequencesScore*2) + contentManipulationScore + violationOfPlatformPoliciesScore);
    //might not be completely accurate because float not supported 
    uint256 totalScore = weightedScore/noVoters;

    return totalScore;

    // TODO: add the different scenarios here

  }

  function getRegisteredLength() public view returns(uint256) {
    return registered.length;
  }

  function getHarmfulConsequencesScore() public view returns(uint256) {
    return harmfulConsequencesScore;
  }

  function getFactualAccuracyScore() public view returns(uint256) {
    return factualAccuracyScore;
  }

}