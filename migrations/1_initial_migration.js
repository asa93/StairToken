const stairToken = artifacts.require("StairToken");
const balanceTracker = artifacts.require("BalanceTracker");
const IERC20 = artifacts.require("IERC20");
const SafeMath = artifacts.require("SafeMath");

module.exports = async function(deployer, network, accounts) {

  const zeroAddr="0x0000000000000000000000000000000000000000"
  await deployer.deploy(stairToken, 1000000, accounts[0], accounts[2], accounts[2], accounts[2], zeroAddr, zeroAddr);
  await deployer.deploy(balanceTracker, stairToken.address, accounts[2], accounts[2], accounts[2], zeroAddr, zeroAddr, zeroAddr);

}
