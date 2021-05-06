const stairToken = artifacts.require("StairToken");
const balanceTracker = artifacts.require("BalanceTracker");

module.exports = function(deployer) {
  deployer.deploy(stairToken, 1000000);
  deployer.deploy(balanceTracker);
}
