// SPDX-License-Identifier: GPL-3.0
    
pragma solidity >=0.4.22 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
 
import "../STAIR/Token.sol";
import "../STAIR/BalanceTracker.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    
    
    uint256 totalTokens = 1000*1000*1000;
    
    address testAddr = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        STAIRToken token = new STAIRToken(totalTokens);
        BalanceTracker balanceTracker = new BalanceTracker();
        
        Assert.equal(BalanceTracker.getContractAddress(), 10, "error getContractAddress");
        
        token.setBalanceTracker();
        
        token.transfer(testAddr,10);
        
        Assert.equal(token.balanceOf(testAddr), 10, "error balance");
    }
    
    
 
}
