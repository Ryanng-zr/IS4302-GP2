const AcceptanceVoting = artifacts.require('../contracts/AcceptanceVoting.sol');
const User = artifacts.require('../contracts/User.sol');
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

contract('AcceptanceVoting', (accounts) => {
  let acceptanceVotingInstance;
  let userInstance;

  before(async () => {
    userInstance = await User.deployed();
    acceptanceVotingInstance = await AcceptanceVoting.deployed();
  });

  it('should allow adding of voter', async () => {
    // user id = 0
    await userInstance.addUser('Alice', 'alice@example.com', {
      from: accounts[0],
    });

    // user id = 1
    let voter1 = await userInstance.addUser('Mary', 'mary@example.com', {
      from: accounts[1],
    });

    await userInstance.updateUserType(1, 1, {
      from: accounts[0],
    });

    let result = await acceptanceVotingInstance.addVoter(0, {
      from: accounts[0],
    });

    await acceptanceVotingInstance.addVoter(1, {
      from: accounts[1],
    });

    truffleAssert.eventEmitted(result, 'voter_added');

    length = await acceptanceVotingInstance.getRegisteredLength();

    assert.strictEqual(length.words[0], 2, 'Add Voters doesnt work');

    //voter already registered
    await truffleAssert.reverts(
      acceptanceVotingInstance.addVoter(1, {
        from: accounts[1],
      }),
      'You are already registered',
    );

    //user id dont exist
    await truffleAssert.reverts(
      acceptanceVotingInstance.addVoter(3, {
        from: accounts[3],
      }),
      'User ID does not exist',
    );
  });

  it('can vote', async () => {
    // factualAccuracy - 1, maliciousIntent - 1, contentManipulation - 0, harmfulConsequences - 0, violationOfPlatformPolicies - 0
    let vote1 = await acceptanceVotingInstance.vote(
      0,
      true,
      true,
      false,
      false,
      false,
      { from: accounts[0] },
    );
    truffleAssert.eventEmitted(vote1, 'voted');

    // total scores: factualAccuracy - 1, maliciousIntent - 1, contentManipulation - 0, harmfulConsequences - 0, violationOfPlatformPolicies - 0
    //((maliciousIntentScore*2) + (factualAccuracyScore*4) + (harmfulConsequencesScore*2) + contentManipulationScore + violationOfPlatformPoliciesScore)
    // calculated score: 6/1
    let score1 =
      await acceptanceVotingInstance.calculateResultBasedOnRegularWeightage();

    assert.strictEqual(
      score1.words[0],
      6,
      'calculateResultBasedOnRegularWeightage is calculated wrongly!',
    );

    // factualAccuracy - 0, maliciousIntent - 0, contentManipulation - 0, harmfulConsequences - 3, violationOfPlatformPolicies - 3
    let vote2 = await acceptanceVotingInstance.vote(
      1,
      false,
      false,
      false,
      true,
      true,
      {
        from: accounts[1],
      },
    );

    truffleAssert.eventEmitted(vote2, 'voted');

    //check harmfulconsequences score because user1 voted 0 and voter1 voted 1
    let harmfulScore =
      await acceptanceVotingInstance.getHarmfulConsequencesScore();

    assert.strictEqual(harmfulScore.words[0], 3, 'voter vote did not x3');

    // total scores: factualAccuracy - 1, maliciousIntent - 1, contentManipulation - 0, harmfulConsequences - 3, violationOfPlatformPolicies - 3
    //((maliciousIntentScore*2) + (factualAccuracyScore*4) + (harmfulConsequencesScore*2) + contentManipulationScore + violationOfPlatformPoliciesScore)
    // calculated score: 12/4
    let total =
      await acceptanceVotingInstance.calculateResultBasedOnRegularWeightage();

    assert.strictEqual(
      total.words[0],
      3,
      'calculateResultBasedOnRegularWeightage is calculated wrongly!',
    );
  });
});
