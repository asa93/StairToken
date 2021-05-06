pragma solidity 0.7.3;

interface IERC201 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract STAIRToken is IERC201 {
    
    address owner;
       modifier onlyOwner {
        require(
            msg.sender == owner
        );
        _;
    }
    
    string public constant name = "ESCALIER";
    string public constant symbol = "ESC";
    uint8 public constant decimals = 0;


 


    mapping(address => uint256) balances;
    mapping(address => uint8) whitelist;
    address[] pioneers;
    address[] holders;
    
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;
    
    
    uint256 constant poolCommission = 10;
    uint256 constant teamShare = 40;
    uint256 constant holderShare = 60;
    uint256 constant pioneerShare = 3; 
    uint256 constant minimumHolding = 100;
    
    bool commissionEnabled = true;
    address poolAddress;
    address teamAddress;
    uint256  level = 10;  
    
   

    using SafeMath2 for uint256;
    
    BalanceTracker balanceTracker;


   constructor(uint256 total
  // , address poolAddress_ , address teamAddress_, uint256 level_
   ) public {
    totalSupply_ = total;
    balances[msg.sender] = totalSupply_;
    
    owner = msg.sender;
    
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
        /*
        if(commissionEnabled && whitelist[receiver]!=1 && whitelist[msg.sender]!=1 ){
            uint256 userTokens = numTokens * (100-poolCommission)/100;
            uint256 poolTokens = numTokens  * (poolCommission)/100;
            balances[msg.sender] = balances[msg.sender].sub(numTokens);
            balances[receiver] = balances[receiver].add(userTokens);
            balances[poolAddress] = balances[poolAddress].add(poolTokens);
            emit Transfer(msg.sender, receiver, userTokens);
            emit Transfer(msg.sender, poolAddress, poolTokens);
            }
        else {
             balances[msg.sender] = balances[msg.sender].sub(numTokens);
             balances[receiver] = balances[receiver].add(numTokens);
            emit Transfer(msg.sender, receiver, numTokens);
        }
        */
        
        //pool 
     //   addOwner(receiver);
        //if(balances[poolAddress] >= level) poolDispatch();
        
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
        
        balances[from] = balances[from].add(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(from, to, amount);
        
        balanceTracker.updateUserBalance(from);
        balanceTracker.updateUserBalance(to);
     
        return true;
        
    }
    function whitelistAddress(address addr) public onlyOwner{
        if(whitelist[addr]==1)
        whitelist[addr] = 0;
        else 
        whitelist[addr]=1;
    }
    
    
    
    function addOwner(address newOwner) private{
        for (uint i=0; i<holders.length; i++) {
            if(holders[i] == newOwner) return;
        }
        holders.push(newOwner);
    }
    
    function addPioneer(address newPioneer) private{
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
    
    
    
    
    //toupdate
    function poolDispatch() private{
        address[] memory rankedHolders;
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
        
        else if(rankedHolders.length ==2){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens/2);
            balances[balanceTracker.getUserAtRank(2)] = balances[rankedHolders[1]].add(holderTokens/2);
            balances[poolAddress] = balances[poolAddress].sub(holderTokens);
        
        }
        else{
             uint256 pioneersTokens= holderTokens*2/100;
             holderTokens = holderTokens.sub(pioneersTokens);
             
             //Calculate token alocation
            uint256 top20Tokens;
            uint256 top50Tokens;
            uint256 top100Tokens ;
            if (eligibleHolders.mul(20).div(100)==0){
                top20Tokens = 0;
            }
            else{
                top20Tokens = (holderTokens.mul(50).div(100)).div(eligibleHolders.mul(20).div(100)); 
           
            }
             if (eligibleHolders.mul(30).div(100)==0){
                top50Tokens = 0;
            }
            else{
                top50Tokens = (holderTokens.mul(30).div(100)).div(eligibleHolders.mul(30).div(100)); 
           
            }
            
             if (eligibleHolders.mul(50).div(100)==0){
                top100Tokens = 0;
            }
            else{
                top100Tokens = (holderTokens.mul(18).div(100)).div(eligibleHolders.mul(50).div(100)); 
            }
             
             
            for (uint i=1; i<=eligibleHolders; i.add(1)) {
                if(isPioneer(balanceTracker.getUserAtRank(i))){
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( pioneersTokens / pioneers.length );
                    balances[poolAddress] =  balances[ poolAddress ].sub( pioneersTokens /  pioneers.length );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), pioneersTokens /  pioneers.length);
                }
                
                if(i <= (20 * eligibleHolders)/100 ){
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top20Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top20Tokens );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), top20Tokens);
                    
                }
                else if(i <= (50 * eligibleHolders)/100 ){
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top50Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top50Tokens );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), top50Tokens);
                }
                else{
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top100Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top100Tokens );
                    emit Transfer(poolAddress, balanceTracker.getUserAtRank(i), top100Tokens);
                }
                
                // balances[rankedHolders[i]] = balances[rankedHolders[i]].add( level/(rankedHolders.length ) );
                  //  balances[poolAddress] = balances[ poolAddress ].sub( level / ( rankedHolders.length) );
                    
                //emit Transfer(poolAddress, rankedHolders[i], level / ( rankedHolders.length )); 
                
                     
            }
        }

        
    }
    
    function forceDispatch() public onlyOwner{
        poolDispatch();
        
    }
        //getters
    
    function isWhitelisted(address addr) public view returns (uint256){
        return whitelist[addr];
         
    }
    
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
    
    function enableCommission() public view returns(bool){
        return commissionEnabled;
    }
    
    function getContractAddress() public  view returns (address) {
    return address(this);
    }
    
    
    //setters (owner)
    
    function setPoolAddress(address addr) public onlyOwner{
        poolAddress = addr;
    }
    

    
    function enableCommission(bool enable) public onlyOwner{
        commissionEnabled = enable;
    }
    
    function setTeamAddress(address addr) public onlyOwner{
        teamAddress = addr;
    }
    
    function setLevel(uint256 level_) public onlyOwner{
        level = level_;
    }
    
    function setBalanceTracker(address addr) public onlyOwner{
        balanceTracker = BalanceTracker(addr);
    }
    
    function burn(uint256 amount) public onlyOwner{
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
    }
    
    
    
}

interface BalanceTracker {

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

    function treeBelow(
        uint256 value) external view returns (uint256);

    function treeAbove(
        uint256 value) external view returns (uint256);

    function treeCount() external view returns (uint256);
 
    function treeValueAtRank(uint256 rank) external view returns (uint256); 
}


library SafeMath2 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}