const stairToken = artifacts.require("StairToken");
const balanceTracker = artifacts.require("BalanceTracker");
const IERC20 = artifacts.require("IERC20");
const SafeMath = artifacts.require("SafeMath");

module.exports = async function(deployer) {
  await deployer.deploy(stairToken, 1000000);
  await deployer.deploy(balanceTracker, stairToken.address);


}
