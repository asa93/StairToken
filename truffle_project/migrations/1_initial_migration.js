const stairToken = artifacts.require("StairToken");
const balanceTracker = artifacts.require("BalanceTracker");
const IERC20 = artifacts.require("IERC20");
const SafeMath = artifacts.require("SafeMath");

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(stairToken, 1000000, accounts[1], accounts[2], accounts[3], accounts[4]);
  await deployer.deploy(balanceTracker, stairToken.address, accounts[2], accounts[3], accounts[4]);

}
