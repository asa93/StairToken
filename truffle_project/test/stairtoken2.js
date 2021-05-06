 
const stairToken_ = artifacts.require("StairToken");
const balanceTracker_ = artifacts.require("BalanceTracker");



contract('StairToken', (accounts) => {
  const poolAddress = accounts[1]

  it('should put 10000 STAIR in the first account', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()

    await stairToken.setBalanceTracker(balanceTracker.address)

    //assert.equal((await stairToken.totalSupply()).toNumber(), 1000000, "Error getTotalSupply");
    //
    
    await stairToken.transfer(accounts[2], 190)
    await stairToken.transfer(accounts[3], 180)
    await stairToken.transfer(accounts[4], 170)
    await stairToken.transfer(accounts[5], 160)

    await stairToken.setPoolAddress(poolAddress)
    await stairToken.transfer(poolAddress, 100)
    //assert.equal((await balanceTracker.treeCount()).toNumber(), 2, "Error treeCount 2");

    //assert.equal(await stairToken.balanceOf(accounts[1]), 100, "Error transfer1");

    assert.equal((await stairToken.getEligibleHolders()).toNumber(),5,"error eligibleHolders")

    assert.equal((await stairToken.top20Tokens()).toNumber(),30,"error top20tokens")
    assert.equal((await stairToken.top50Tokens()).toNumber(),18,"error top50tokens")
    assert.equal((await stairToken.top100Tokens()).toNumber(),3,"error top100tokens")


    assert.equal((await balanceTracker.treeAbove(191)).toNumber(), 1, "Error treeCount should be 3");

    let ownerTokens = (await stairToken.balanceOf(accounts[0])).toNumber();

    await stairToken.forceDispatch();

    assert.equal((await stairToken.balanceOf(poolAddress)).toNumber(),3,"finalPoolBalance is not correct")
    

    assert.equal((await balanceTracker.treeCount()).toNumber(), 5, "Error treeCount should be 3");
    assert.equal((await balanceTracker.treeAbove(194)).toNumber(), 1, "Error treeCount should be 3");

    assert.equal((await stairToken.balanceOf(accounts[0])).toNumber(),ownerTokens+30," accounts owner balance error")
    assert.equal((await stairToken.balanceOf(accounts[2])).toNumber(),208," accounts 2 balance error")
    assert.equal((await stairToken.balanceOf(accounts[3])).toNumber(),183," accounts 3 balance error")
    assert.equal((await stairToken.balanceOf(accounts[4])).toNumber(),173,"accounts 4 balance error")
    assert.equal((await stairToken.balanceOf(accounts[5])).toNumber(),163,"accounts 5 balance error")

  });
/*
  it('should call a function that depends on a linked library', async () => {
    const metaCoinInstance = await MetaCoin.deployed();
    const metaCoinBalance = (await metaCoinInstance.getBalance.call(accounts[0])).toNumber();
    const metaCoinEthBalance = (await metaCoinInstance.getBalanceInEth.call(accounts[0])).toNumber();

    assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
  });
  it('should send coin correctly', async () => {
    const metaCoinInstance = await MetaCoin.deployed();

    // Setup 2 accounts.
    const accountOne = accounts[0];
    const accountTwo = accounts[1];

    // Get initial balances of first and second account.
    const accountOneStartingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
    const accountTwoStartingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();

    // Make transaction from first account to second.
    const amount = 10;
    await metaCoinInstance.sendCoin(accountTwo, amount, { from: accountOne });

    // Get balances of first and second account after the transactions.
    const accountOneEndingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
    const accountTwoEndingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();


    assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount, "Amount wasn't correctly taken from the sender");
    assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
  });
  */
});
