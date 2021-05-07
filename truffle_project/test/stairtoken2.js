 
const stairToken_ = artifacts.require("StairToken");
const balanceTracker_ = artifacts.require("BalanceTracker");



contract('StairToken',  (accounts) => {
  const poolAddress = accounts[1]


 
  it('should dispatch pool amount correctly', async () => {
    
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    await stairToken.setBalanceTracker(balanceTracker.address)
      
    await stairToken.transfer(accounts[2], 190)
    await stairToken.transfer(accounts[3], 180)
    await stairToken.transfer(accounts[4], 170)
    await stairToken.transfer(accounts[5], 160)

    await stairToken.setPoolAddress(poolAddress)
    await stairToken.transfer(poolAddress, 100)
    //assert.equal((await balanceTracker.treeCount()).toNumber(), 2, "Error treeCount 2");

    //assert.equal(await stairToken.balanceOf(accounts[1]), 100, "Error transfer1");

    assert.equal((await stairToken.getEligibleHolders()).toNumber(),5,"error eligibleHolders")
    //assert.equal((await stairToken.balanceOf(accounts[5])).toNumber(),163,"accounts 5 balance error")
    //assert.equal(await balanceTracker.getUserAtRank(1),accounts[0],"error balanceTracker.getUserAtRank(i)")
    
    console.log((await balanceTracker.treeValueAtRank(1)).toNumber(), "treeValueAtRank1")
    console.log((await balanceTracker.treeValueAtRank(2)).toNumber(), "treeValueAtRank2")
    console.log((await balanceTracker.treeValueAtRank(3)).toNumber(), "treeValueAtRank3")
    console.log((await balanceTracker.treeValueAtRank(4)).toNumber(), "treeValueAtRank4")
    console.log((await balanceTracker.treeValueAtRank(5)).toNumber(), "treeValueAtRank4")
    
    console.log((await balanceTracker.getUserAtRank(1)), "getUserAtRank1")
    console.log((await balanceTracker.getUserAtRank(2)), "getUserAtRank2")
    console.log((await balanceTracker.getUserAtRank(3)), "getUserAtRank3")
    console.log((await balanceTracker.getUserAtRank(4)), "getUserAtRank4")
    console.log((await balanceTracker.getUserAtRank(5)), "getUserAtRank5")
 

    assert.equal((await stairToken.top20Tokens()).toNumber(),30,"error top20tokens")
    assert.equal((await stairToken.top50Tokens()).toNumber(),18,"error top50tokens")
    assert.equal((await stairToken.top100Tokens()).toNumber(),3,"error top100tokens")


    await stairToken.forceDispatch(); ////////////////////////////////////////

    assert.equal((await stairToken.balanceOf(poolAddress)).toNumber(),3,"finalPoolBalance is not correct")
    

    console.log((await stairToken.balanceOf(accounts[0])).toNumber(), "accounts balance 0 should be", 100000)
    console.log((await stairToken.balanceOf(accounts[2])).toNumber(), "accounts balance 2 should be", 208 )
    console.log((await stairToken.balanceOf(accounts[3])).toNumber(), "accounts balance 3 should be", 183)
    console.log((await stairToken.balanceOf(accounts[4])).toNumber(), "accounts balance 4 should be", 173)
    console.log((await stairToken.balanceOf(accounts[5])).toNumber(), "accounts balance 5 should be", 163 )

 

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
