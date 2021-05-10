pragma solidity 0.7.3;

import "./IERC20.sol";
import "./IBalanceTracker.sol";
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
    uint256 totalSupply_;
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    
    bool airdropDone=false;
    bool feesEnabled = true; //tmp ?
    address stepWalletAddress;
    address teamAddressA; //  to hardcode here
    address teamAddressB; //  to hardcode  here
    address teamAddressC; //  to hardcode here
    address operationsAddress; //  to hardcode here
    address charityAddress; //  to hardcode here
    address presaleAddress; //  to hardcode here

    //stepwallet parameters
    uint256  level = 100; //tmp replace by 1million
    uint256 lastAllocationTime=block.timestamp;

    mapping(address => bool) pioneers;
    uint256 pioneersCount=0;


    using SafeMath for uint256;
    
    IBalanceTracker balanceTracker;

   constructor(uint256 total
  , address stepWalletAddress_ , //tmp to hardcode 
    address teamAddressA_,//tmp to hardcode 
    address teamAddressB_,//tmp to hardcode 
    address teamAddressC_,
    address operationsAddress_,
    address charityAddress_
   ) public {
    totalSupply_ = total;
    balances[msg.sender] = totalSupply_;
    owner = msg.sender;

    stepWalletAddress = stepWalletAddress_;
    teamAddressA = teamAddressA_; //tmp to hardcode 
    teamAddressB = teamAddressB_; //tmp to hardcode 
    teamAddressC = teamAddressC_;//tmp to hardcode 
    operationsAddress = operationsAddress_; //tmp to hardcode
    charityAddress = charityAddress_;
    
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
        
        //Not charging fees from any transactions with the presaleAddress
        if( to==presaleAddress || from==presaleAddress || !feesEnabled ||  balanceTracker.isAddressIneligible(from)){
            balances[from] = balances[from].sub(amount);
            balances[to] = balances[to].add(amount);
            emit Transfer(from, to, amount);
            }
        else {
        
            uint256 userTokens = amount.mul(90).div(100);
            uint256 stepTokens = amount.mul(10).div(100);
            balances[from] = balances[from].sub(amount);
            balances[to] = balances[to].add(userTokens);
            balances[stepWalletAddress] = balances[stepWalletAddress].add(stepTokens);

            emit Transfer(from, to, userTokens);
            emit Transfer(from, stepWalletAddress, stepTokens);
        }
        

        balanceTracker.updateUserBalance(from);
        balanceTracker.updateUserBalance(to);
        
        
        //allocate if stepWallet level is reached or lastAllocation was 7 days ago
        if(balances[stepWalletAddress] >= level || ( block.timestamp - lastAllocationTime) > 604800 ) allocateStepWallet();

        if(from == presaleAddress && !pioneers[to]){
            pioneers[to] = true;
            pioneersCount = pioneersCount.add(1);
        }
            
     
        return true;
        
    }
 
    
    function getEligibleHolders() public view returns(uint256){
        return balanceTracker.treeAbove(10);
    }

    //TEMP 
    // function top20Tokens() public view returns(uint256){
    //     uint256 eligibleHolders = balanceTracker.treeAbove(10);
    //     uint256 teamTokens = balances[ stepWalletAddress ]*teamShare/100;
    //     uint256 holderTokens = balances[stepWalletAddress] - teamTokens;
    //     uint256 top20Tokens;
    //         if (eligibleHolders.mul(20).div(100)==0)
    //             top20Tokens = 0;
            
    //         else
    //             top20Tokens = (holderTokens.mul(50).div(100)).div(eligibleHolders.mul(20).div(100)); 
           
    //        return top20Tokens;
    // }
    // //TEMP 
    // function top50Tokens() public view returns(uint256){
    //     uint256 eligibleHolders = balanceTracker.treeAbove(10);
    //     uint256 teamTokens = balances[ stepWalletAddress ]*teamShare/100;
    //     uint256 holderTokens = balances[stepWalletAddress] - teamTokens;
    //     uint256 top50Tokens;
    //     uint256 top20Tokens = top20Tokens();
    //     uint256 percent = 30;
        
         
    //         if (eligibleHolders.mul(30).div(100)==0)
    //             top50Tokens = 0;
            
    //         else
    //             top50Tokens = (holderTokens.mul(30).div(100)).div(eligibleHolders.mul(30).div(100)); 

    //         return top50Tokens;
           
    // }
    // //TEMP 
    // function top100Tokens() public view returns(uint256){
    //     uint256 eligibleHolders = balanceTracker.treeAbove(10);
    //     uint256 teamTokens = balances[ stepWalletAddress ]*teamShare/100;
    //     uint256 holderTokens = balances[stepWalletAddress] - teamTokens;
    //     uint256 top100Tokens;
    //         if (eligibleHolders.mul(50).div(100)==0)
    //             top100Tokens = 0;
            
    //         else
    //             top100Tokens = (holderTokens.mul(18).div(100)).div(  eligibleHolders.sub(eligibleHolders.mul(30).div(100)).sub(eligibleHolders.mul(20).div(100))   ); 

    //        return top100Tokens;
    // }


    function allocateStepWallet() private{ 

        if(balances[stepWalletAddress] == 0) return;
        lastAllocationTime = block.timestamp;

        //burn 10 % of step wallet 
        burn(balances[stepWalletAddress]*10/100);

        uint256 teamTokens;
        uint256 holderTokens;
        uint256 eligibleHolders = balanceTracker.treeAbove(10);

        //only allocate 25% of stepWallet if one week has elapsed
        if(( block.timestamp - lastAllocationTime) > 604800){
            teamTokens = balances[stepWalletAddress].mul(30).div(100).mul(25).div(100);
            holderTokens = balances[stepWalletAddress].mul(25).div(100) - teamTokens;
        }
        else{
        teamTokens = balances[stepWalletAddress].mul(30).div(100);
        holderTokens = balances[stepWalletAddress] - teamTokens;
        }

        balances[teamAddressA] =  balances[teamAddressA].add(teamTokens.mul(45).div(100));
        balances[teamAddressB] =  balances[teamAddressB].add(teamTokens.mul(35).div(100));
        balances[teamAddressC] =  balances[teamAddressC].add(teamTokens.mul(20).div(100));
        balances[stepWalletAddress] =  balances[ stepWalletAddress ].sub( teamTokens );
        
        if(eligibleHolders == 0) return;
        
        else if(eligibleHolders == 1){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens);
            balances[stepWalletAddress] = balances[stepWalletAddress].sub(holderTokens);
        }
        
        else if(eligibleHolders ==2){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens/2);
            balances[balanceTracker.getUserAtRank(2)] = balances[balanceTracker.getUserAtRank(2)].add(holderTokens/2);
            balances[stepWalletAddress] = balances[stepWalletAddress].sub(holderTokens);
        
        }
        else{
             uint256 pioneersTokens= holderTokens.mul(2).div(100);
             holderTokens = holderTokens.sub(pioneersTokens);
             
             balances[charityAddress] = balances[charityAddress].add(holderTokens.mul(10).div(100)); 
             balances[stepWalletAddress] = balances[stepWalletAddress].sub(holderTokens.mul(10).div(100));

             balances[operationsAddress] = balances[operationsAddress].add(holderTokens.mul(3).div(100));
             balances[stepWalletAddress] = balances[stepWalletAddress].sub(holderTokens.mul(3).div(100));

            // Calculate token alocation
            uint256 top20Tokens;
            uint256 top50Tokens;
            uint256 top100Tokens ;

            if (eligibleHolders.mul(20).div(100)==0)
                top20Tokens = 0;
            else
                top20Tokens = (holderTokens.mul(40).div(100)).div(eligibleHolders.mul(20).div(100)); 

             if (eligibleHolders.mul(30).div(100)==0)
                top50Tokens = 0;
            else
                top50Tokens = (holderTokens.mul(30).div(100)).div(eligibleHolders.mul(30).div(100)); 

             if (eligibleHolders.mul(50).div(100)==0)
                top100Tokens = 0;
            else
                top100Tokens = (holderTokens.mul(15).div(100)).div(  eligibleHolders.sub(eligibleHolders.mul(30).div(100)).sub(eligibleHolders.mul(20).div(100))   );
            
             
            uint256 treeCount = balanceTracker.treeCount();
            for (uint256 i=treeCount; i>treeCount-eligibleHolders; i--) {
                 address currentUser = balanceTracker.getUserAtRank(i);

                //pioneers share 2% of pioneers minimumHoldingPioneer
                if(pioneers[currentUser] && balances[currentUser] > 2000 ){
                    balances[currentUser] = balances[currentUser].add( pioneersTokens / pioneersCount );
                    balances[stepWalletAddress] =  balances[ stepWalletAddress ].sub( pioneersTokens /  pioneersCount );
                    emit Transfer(stepWalletAddress, currentUser, pioneersTokens /  pioneersCount);
                }
                
                //top 20% holders get 40% of holders pool
                if(i > treeCount - eligibleHolders.mul(20).div(100) ){
                    
                    balances[currentUser] = balances[currentUser].add( top20Tokens );
                    balances[stepWalletAddress] =  balances[ stepWalletAddress ].sub( top20Tokens );
                    emit Transfer(stepWalletAddress, currentUser, top20Tokens);
                    
                }
                //top 50% holders get 20% of pool (50-20 = 30% of holders)
                else if(i > treeCount - eligibleHolders.mul(20).div(100).add( eligibleHolders.mul(30).div(100) ) ){

                    balances[currentUser] = balances[currentUser].add( top50Tokens );
                    balances[stepWalletAddress] =  balances[ stepWalletAddress ].sub( top50Tokens );
                    emit Transfer(stepWalletAddress, currentUser, top50Tokens);
                }
                //remaining 50% of holders get 15% of pool
                else{

                    balances[currentUser] = balances[currentUser].add( top100Tokens );
                    balances[stepWalletAddress] =  balances[ stepWalletAddress ].sub( top100Tokens );
                    emit Transfer(stepWalletAddress, currentUser, top100Tokens);
                }
                
                
 
                     
            }
        }

        
    }
    
    function forceAllocation() public onlyOwner{
        allocateStepWallet();
        
    }
        //getters
    
   
 
    
    function getLevel() public  view returns (uint256) {
    return level;
    }
    
    function enableFees() public view returns(bool){
        return feesEnabled;
    }
    
    function doAirdrop( address[] memory dests) public
    returns (uint256) {
        require(airdropDone==false);
        require(msg.sender==operationsAddress);
        uint256 i = 0;
        while (i < dests.length) {
        //set correct airdrop value
        transfer( dests[i], 100 );
        i += 1;
        }
        airdropDone=true;
        return(i);
    }
    //setters (owner)
    
    function enableFees(bool enable) public onlyOwner{
        feesEnabled = enable;
    }
    
    function setLevel(uint256 level_) public onlyOwner{
        level = level_;
    }
    
    function setBalanceTracker(address addr) public onlyOwner{
        balanceTracker = IBalanceTracker(addr);
    }
    function setPresaleAddress(address addr) public onlyOwner{
        presaleAddress = addr;
        balanceTracker.makeAddressIneligible(addr);
    }
    //tmp
    /*
    function setstepWalletAddress(address addr) public onlyOwner{
        stepWalletAddress = addr;
        balanceTracker.makeAddressIneligible(addr);
    } 
    */
    /*
    function addPioneer(address addr) public onlyOwner{
        //if( !pioneers[addr]){
            pioneers[addr] = true;
            pioneersCount = pioneersCount.add(1);
    }

    function getPioneer(address addr) public view returns(bool){
        //if( !pioneers[addr]){
            return pioneers[addr];
           // return pioneersCount;
    }
    */
    
  
    function burn(uint256 _value) private {
    require(_value > 0);
    require(_value <= balances[stepWalletAddress]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = stepWalletAddress;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    
}
    
    
}



 