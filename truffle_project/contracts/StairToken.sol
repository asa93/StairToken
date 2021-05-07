pragma solidity 0.7.3;

import "./IERC20.sol";
import "./SafeMath.sol";


contract STAIRToken is IERC20 {
    
    address owner;
       modifier onlyOwner {
        require(
            msg.sender == owner
        );
        _;
    }
    
    string public constant name = "STAIR";
    string public constant symbol = "STAIR";
    uint8 public constant decimals = 0;


    mapping(address => uint256) balances;
 
    address[] pioneers;
    address[] holders;
    
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;
    
    
    uint256 constant poolCommission = 10;
    uint256 constant teamShare = 40;
    uint256 constant holderShare = 60;
    uint256 constant pioneerShare = 2; 
    uint256 constant minimumHolding = 10;
    
    bool feesEnabled = true;
    address poolAddress;
    address teamAddress;
    uint256  level = 100;  
    
   

    using SafeMath for uint256;
    
    BalanceTrackerI balanceTracker;


   constructor(uint256 total
  // , address poolAddress_ , address teamAddress_, uint256 level_
   ) public {
    totalSupply_ = total;
    balances[msg.sender] = totalSupply_;
    
    owner = msg.sender;
    //balanceTracker.makeAddressIneligible(msg.sender);
    //level =  level_;
    //poolAddress = poolAddress_;
    //teamAddress = teamAddress_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
         
        transfer_(msg.sender, receiver, numTokens);

        
        return true;
    }

    
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        transfer_(owner, buyer, numTokens);
        
        return true;
    }
    
    //Overrides the superclass implementation to handle custom logic
    //such as taking fees, burning tokens, and supplying liquidity to PancakeSwap
    
    function transfer_(address from, address to, uint256 amount) public returns(bool){
        
        
        if(feesEnabled &&  !balanceTracker.isAddressIneligible(from)){
            uint256 userTokens = amount.mul(100-poolCommission).div(100);
            uint256 poolTokens = amount.mul(poolCommission).div(100);
            balances[from] = balances[from].sub(amount);
            balances[to] = balances[to].add(userTokens);
            balances[poolAddress] = balances[poolAddress].add(poolTokens);

            emit Transfer(from, to, userTokens);
            emit Transfer(from, poolAddress, poolTokens);
            }
        else {
        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(from, to, amount);
        }
        

        balanceTracker.updateUserBalance(from);
        balanceTracker.updateUserBalance(to);
        
        
        if(balances[poolAddress] >= level) poolDispatch();
     
        return true;
        
    }
 
    
    
    function addOwner(address newOwner) private{
        for (uint i=0; i<holders.length; i++) {
            if(holders[i] == newOwner) return;
        }
        holders.push(newOwner);
    }
    
    function addPioneer(address newPioneer) public{
        for (uint i=0; i<pioneers.length; i++) {
            if(pioneers[i] == newPioneer) return;
        }
        pioneers.push(newPioneer);
    }
    
    function isPioneer(address pionner) public returns(bool){
        for (uint i=0; i<pioneers.length; i++) {
            if(pioneers[i] == pionner) return true;
        }
        return false;
    }
    
    
    function getEligibleHolders() public view returns(uint256){
        return balanceTracker.treeAbove(minimumHolding);
    }

    //TEMP 
    function top20Tokens() public view returns(uint256){
        uint256 eligibleHolders = balanceTracker.treeAbove(minimumHolding);
        uint256 teamTokens = balances[ poolAddress ]*teamShare/100;
        uint256 holderTokens = balances[poolAddress] - teamTokens;
        uint256 top20Tokens;
            if (eligibleHolders.mul(20).div(100)==0)
                top20Tokens = 0;
            
            else
                top20Tokens = (holderTokens.mul(50).div(100)).div(eligibleHolders.mul(20).div(100)); 
           
           return top20Tokens;
    }
    //TEMP 
    function top50Tokens() public view returns(uint256){
        uint256 eligibleHolders = balanceTracker.treeAbove(minimumHolding);
        uint256 teamTokens = balances[ poolAddress ]*teamShare/100;
        uint256 holderTokens = balances[poolAddress] - teamTokens;
        uint256 top50Tokens;
        uint256 top20Tokens = top20Tokens();
        uint256 percent = 30;
        
         
            if (eligibleHolders.mul(30).div(100)==0)
                top50Tokens = 0;
            
            else
                top50Tokens = (holderTokens.mul(30).div(100)).div(eligibleHolders.mul(30).div(100)); 

            return top50Tokens;
           
    }
    //TEMP 
    function top100Tokens() public view returns(uint256){
        uint256 eligibleHolders = balanceTracker.treeAbove(minimumHolding);
        uint256 teamTokens = balances[ poolAddress ]*teamShare/100;
        uint256 holderTokens = balances[poolAddress] - teamTokens;
        uint256 top100Tokens;
            if (eligibleHolders.mul(50).div(100)==0)
                top100Tokens = 0;
            
            else
                top100Tokens = (holderTokens.mul(18).div(100)).div(  eligibleHolders.sub(eligibleHolders.mul(30).div(100)).sub(eligibleHolders.mul(20).div(100))   ); 

           return top100Tokens;
    }

 
    
    //toupdate
    function poolDispatch() private{
       
        uint256 eligibleHolders = balanceTracker.treeAbove(minimumHolding);
        uint256 teamTokens = balances[ poolAddress ]*teamShare/100;
        uint256 holderTokens = balances[poolAddress] - teamTokens;
        
        
        balances[teamAddress] =  balances[teamAddress].add(teamTokens);
        balances[poolAddress] =  balances[ poolAddress ].sub( teamTokens );
        
        if(eligibleHolders == 0) return;
        
        else if(eligibleHolders == 1){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens);
            balances[poolAddress] = balances[poolAddress].sub(holderTokens);
        }
        
        else if(eligibleHolders ==2){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens/2);
            balances[balanceTracker.getUserAtRank(2)] = balances[balanceTracker.getUserAtRank(2)].add(holderTokens/2);
            balances[poolAddress] = balances[poolAddress].sub(holderTokens);
        
        }
        else{
             uint256 pioneersTokens= holderTokens.mul(pioneerShare).div(100);
             holderTokens = holderTokens.sub(pioneersTokens);
             
            // Calculate token alocation
            uint256 top20Tokens;
            uint256 top50Tokens;
            uint256 top100Tokens ;

            if (eligibleHolders.mul(20).div(100)==0)
                top20Tokens = 0;
            else
                top20Tokens = (holderTokens.mul(50).div(100)).div(eligibleHolders.mul(20).div(100)); 

             if (eligibleHolders.mul(30).div(100)==0)
                top50Tokens = 0;
            else
                top50Tokens = (holderTokens.mul(30).div(100)).div(eligibleHolders.mul(30).div(100)); 

             if (eligibleHolders.mul(50).div(100)==0)
                top100Tokens = 0;
            else
                top100Tokens = (holderTokens.mul(18).div(100)).div(  eligibleHolders.sub(eligibleHolders.mul(30).div(100)).sub(eligibleHolders.mul(20).div(100))   );
            
             
            uint256 treeCount = balanceTracker.treeCount();
            for (uint256 i=treeCount; i>treeCount-eligibleHolders; i--) {
                 
                
                if(isPioneer(balanceTracker.getUserAtRank(i))){
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( pioneersTokens / pioneers.length );
                    balances[poolAddress] =  balances[ poolAddress ].sub( pioneersTokens /  pioneers.length );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), pioneersTokens /  pioneers.length);
                }
                
                
                if(i > treeCount - eligibleHolders.mul(20).div(100) ){
                    
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top20Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top20Tokens );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), top20Tokens);
                    
                }
                else if(i > treeCount - eligibleHolders.mul(20).div(100).add( eligibleHolders.mul(30).div(100) ) ){

                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top50Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top50Tokens );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), top50Tokens);
                }
                else{

                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top100Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top100Tokens );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), top100Tokens);
                }
                
                
 
                     
            }
        }

        
    }
    
    function forceDispatch() public onlyOwner{
        poolDispatch();
        
    }
        //getters
    
   
    
    function getPoolBalance() public  view returns (uint256) {
    return balances[poolAddress];
    }
    
    function getPoolAddress() public  view returns (address) {
    return poolAddress;
    }
    
    function getTeamAddress() public  view returns (address) {
    return teamAddress;
    }
    
    function getLevel() public  view returns (uint256) {
    return level;
    }
    
    function enableFees() public view returns(bool){
        return feesEnabled;
    }
    
    function getContractAddress() public  view returns (address) {
    return address(this);
    }
    
    
    //setters (owner)
    
    function setPoolAddress(address addr) public onlyOwner{
        poolAddress = addr;

        balanceTracker.makeAddressIneligible(addr);
    }
    

    
    function enableFees(bool enable) public onlyOwner{
        feesEnabled = enable;
    }
    
    function setTeamAddress(address addr) public onlyOwner{
        teamAddress = addr;
    }
    
    function setLevel(uint256 level_) public onlyOwner{
        level = level_;
    }
    
    function setBalanceTracker(address addr) public onlyOwner{
        balanceTracker = BalanceTrackerI(addr);
    }
    
    function burn(uint256 amount) public onlyOwner{
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
    }
    
    
    
}

interface BalanceTrackerI {

    function updateUserBalance(
        address user) external;

    function getUserAtRank(
        uint256 rank) external view returns (address);

    function getRankForUser(
        address user) external view returns (uint256);

    function getRandomUserMinimumTokenBalance(
        uint256 blockNumber,
        uint256 minimumTokenBalance) external view returns (address);

    function getRandomUserTopPercent(
        uint256 blockNumber,
        uint256 percent,
        uint256 minimumTokenBalance) external view returns (address);

    function getRandomUserTop(
        uint256 blockNumber,
        uint256 top) external view returns (address);


    function makeSenderIneligible() external;
    function makeAddressIneligible(address addr) external;
    function isAddressIneligible(address addr) external view returns(bool);
    function treeBelow(
        uint256 value) external view returns (uint256);

    function treeAbove(
        uint256 value) external view returns (uint256);

    function treeCount() external view returns (uint256);
 
    function treeValueAtRank(uint256 rank) external view returns (uint256); 
}


 