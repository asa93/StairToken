 
const stairToken_ = artifacts.require("StairToken");
const balanceTracker_ = artifacts.require("BalanceTracker");
const truffleAssert = require('truffle-assertions');


contract('StairToken',  (accounts) => {
  const stepWalletAddress = accounts[0];
  const teamAddressA = accounts[2];
  const teamAddressB = accounts[2];
  const teamAddressC = accounts[2];


  const user1 = accounts[3]
  const user2 = accounts[4]
  const user3 = accounts[5]
  const stepFees = 10;

  it('should do this before all', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    await stairToken.setBalanceTracker(balanceTracker.address)
   
  })
  it('should emit event correctly', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    //await stairToken.setPresaleAddress(accounts[5])
    let tx = await stairToken.transfer(user1, 500)

    truffleAssert.prettyPrintEmittedEvents(tx,10)
    
  })
  return
  it('transfer & collect in pool', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    //await stairToken.setPresaleAddress(accounts[5])
    await stairToken.transfer(user1, 1000)
    console.log((await stairToken.balanceOf(user1)).toNumber(), "balance user1")
    console.log(await balanceTracker.getUserAtRank(1),user1, "getUserAtRank1 ")
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), "stepWalletAddress balance ")

    await stairToken.transfer(user1, 900)
    console.log((await stairToken.balanceOf(user1)).toNumber(), "balance user1")
    console.log(await balanceTracker.getUserAtRank(1),user1, "getUserAtRank1 ")
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), "stepWalletAddress balance ")

    await stairToken.transfer(user1, 3000)
    console.log((await stairToken.balanceOf(user1)).toNumber(), "balance user1")
    console.log(await balanceTracker.getUserAtRank(1),user1, "getUserAtRank1 ")
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), "stepWalletAddress balance ")
    
  })
  return 
  it('should airdrop the right amount', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    
    await stairToken.setPresaleAddress(accounts[5])
    await stairToken.doAirdrop([accounts[6]])
    console.log(await stairToken.balanceOf(accounts[6]))
    await stairToken.transfer(accounts[6], 500)
    console.log(await stairToken.balanceOf(stepWalletAddress))
    await stairToken.transfer(accounts[7], 500)
    console.log(await stairToken.balanceOf(stepWalletAddress))
    await stairToken.transfer(accounts[6], 500)
    
   // await stairToken.doAirdrop([accounts[6]])
    console.log(await stairToken.balanceOf(stepWalletAddress))
    console.log((await stairToken.totalSupply()).toNumber())

  })
  return 
  it('should not take fees from or to presaleAddress', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    

    await stairToken.setPresaleAddress(accounts[5])
    await stairToken.transfer(accounts[5], 500)
    

    console.log((await stairToken.balanceOf(accounts[0])).toNumber(), 450, " balance accounts 0"   )
    console.log((await stairToken.balanceOf(accounts[6])).toNumber(), 500, " balance accounts 5"   )
    console.log((await stairToken.balanceOf(accounts[7])).toNumber(), 450, " balance accounts 6"   )
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), 10 , "stepWallet balance"  )

  })

  it('should give money to pioneer', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()
    
    await stairToken.addPioneer(accounts[6])
    console.log((await stairToken.getPioneer(accounts[6])), "pioneer")
    await stairToken.transfer(accounts[7], 500)
    await stairToken.transfer(accounts[6], 500)

    console.log((await stairToken.balanceOf(accounts[0])).toNumber(), 450, " balance accounts 0"   )
    console.log((await stairToken.balanceOf(accounts[7])).toNumber(), 450, " balance accounts 5"   )
    console.log((await stairToken.balanceOf(accounts[6])).toNumber(), 450, " balance accounts 6"   )
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), 50 , "stepWallet balance"  )

  })

  return
  it('should extract fees  correctly', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()

    await stairToken.transfer(accounts[5], 500)

    assert.equal((await stairToken.balanceOf(accounts[5])).toNumber(), 450, "error account2 balance"   )
    assert.equal((await stairToken.balanceOf(stepWalletAddress)).toNumber(), 50 , "error stepWallet balance"  )

  })

  it('should dispatch stepWallet amount after level is reached', async () => {
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()

    await stairToken.transfer(accounts[6], 500)

    console.log((await stairToken.balanceOf(accounts[0])).toNumber(), 999003, " balance accounts 0"   )
    console.log((await stairToken.balanceOf(accounts[5])).toNumber(), 453, " balance accounts 2"   )
    console.log((await stairToken.balanceOf(accounts[6])).toNumber(), 450, " balance accounts 3"   )
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), 51 , "stepWallet balance"  )

    console.log((await stairToken.balanceOf(teamAddressA)).toNumber(), 18 , "error teamBalanceA"  )
    console.log((await stairToken.balanceOf(teamAddressB)).toNumber(), 14 , "error teamBalanceB"  )
    console.log((await stairToken.balanceOf(teamAddressC)).toNumber(), 8 , "error teamBalanceC"  )

    await stairToken.transfer(accounts[7], 500)
    console.log((await stairToken.balanceOf(accounts[0])).toNumber(), 450, " balance accounts 0"   )
    console.log((await stairToken.balanceOf(accounts[5])).toNumber(), 450, " balance accounts 2"   )
    console.log((await stairToken.balanceOf(accounts[6])).toNumber(), 450, " balance accounts 3"   )
    console.log((await stairToken.balanceOf(accounts[7])).toNumber(), 450, " balance accounts 4"   )
    console.log((await stairToken.balanceOf(stepWalletAddress)).toNumber(), 10 , "stepWallet balance"  )

    

  })


  
  return
  it('should dispatch stepWallet amount correctly', async () => {
    
    const stairToken = await stairToken_.deployed();
    const balanceTracker = await balanceTracker_.deployed()


    await stairToken.transfer(accounts[5], 190)
    await stairToken.transfer(accounts[6], 180)
    await stairToken.transfer(accounts[7], 170)
    await stairToken.transfer(accounts[8], 160)

    
    await stairToken.transfer(stepWalletAddress, 100)
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

    assert.equal((await stairToken.balanceOf(stepWalletAddress)).toNumber(),3,"finalstepWalletBalance is not correct")
    

    console.log((await stairToken.balanceOf(accounts[0])).toNumber(), "accounts balance 0 should be", 100000)
    console.log((await stairToken.balanceOf(accounts[5])).toNumber(), "accounts balance 2 should be", 208 )
    console.log((await stairToken.balanceOf(accounts[6])).toNumber(), "accounts balance 3 should be", 183)
    console.log((await stairToken.balanceOf(accounts[7])).toNumber(), "accounts balance 4 should be", 173)
    console.log((await stairToken.balanceOf(accounts[8])).toNumber(), "accounts balance 5 should be", 163 )

 

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
