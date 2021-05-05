pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20Basic is IERC20 {
    
    address owner;
       modifier onlyOwner {
        require(
            msg.sender == owner
        );
        _;
    }
    
    string public constant name = "ESCALIER";
    string public constant symbol = "ESC";
    uint8 public constant decimals = 6;


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


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
    
   

    using SafeMath for uint256;


   constructor(uint256 total, address poolAddress_ , address teamAddress_, uint256 level_) public {
    totalSupply_ = total;
    balances[msg.sender] = totalSupply_;
    poolAddress = poolAddress_;
    level =  level_;
    owner = msg.sender;
    teamAddress = teamAddress_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
         
        
        
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
        
        //pool 
        addOwner(receiver);
        if(balances[poolAddress] >= level) poolDispatch();
        
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
        
         uint256 userTokens = numTokens * (100-poolCommission)/100;
         uint256 poolTokens = numTokens  * (poolCommission)/100;
         
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(userTokens);
        balances[poolAddress] = balances[poolAddress].add(poolTokens);
        emit Transfer(owner, buyer, userTokens);
        emit Transfer(owner, poolAddress, poolTokens);
        
        //pool 
        addOwner(buyer);
        if(balances[poolAddress] > level) poolDispatch();
        
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
    
    
    function sortHolders() private  view returns (address[] memory) {
        address[] memory rankedHolders = holders;
        for (uint i=0; i<holders.length; i++) {
            if(balances[holders[i]]<minimumHolding) break;
            uint256 rank = 0;

            for(uint j=0; j<holders.length;j++){
                if(balances[holders[i]] < balances[holders[j]])
                    rank = rank+1;
                
            }
           // while(true){
                 if(rankedHolders[rank] == address(0x0)  ){
                    rankedHolders[rank] = holders[i];
            //        break ;
                 }
            //     else 
          //          rank = rank+1;
          //  }
           
            
        }
        
        return rankedHolders;
    }
    
    function poolDispatch() private{
        address[] memory rankedHolders = sortHolders();
        
        uint256 teamTokens = balances[ poolAddress ]*teamShare/100;
        uint256 holderTokens = balances[poolAddress] - teamTokens;
        
        
        balances[teamAddress] =  balances[teamAddress].add(teamTokens);
        balances[poolAddress] =  balances[ poolAddress ].sub( teamTokens );
        
        if(rankedHolders.length == 0) return;
        
        else if(rankedHolders.length == 1){
            balances[rankedHolders[0]] = balances[rankedHolders[0]].add(holderTokens);
            balances[poolAddress] = balances[poolAddress].sub(holderTokens);
        }
        
        else if(rankedHolders.length ==2){
            balances[rankedHolders[0]] = balances[rankedHolders[0]].add(holderTokens/2);
            balances[rankedHolders[1]] = balances[rankedHolders[1]].add(holderTokens/2);
            balances[poolAddress] = balances[poolAddress].sub(holderTokens);
        
        }
        else{
             uint256 pioneersTokens= holderTokens*2/100;
             holderTokens = holderTokens.sub(pioneersTokens);
             
             uint256 top20Tokens = (holderTokens*50/100) / (rankedHolders.length*20/100);
             uint256 top50Tokens = (holderTokens*30/100) /  ( rankedHolders.length*30/100);
             uint256 top100Tokens = (holderTokens*18/100) /  (rankedHolders.length*50/100);
             
            for (uint i=0; i<rankedHolders.length; i++) {
                if(isPioneer(rankedHolders[i])){
                    balances[rankedHolders[i]] = balances[rankedHolders[i]].add( pioneersTokens / pioneers.length );
                    balances[poolAddress] =  balances[ poolAddress ].sub( pioneersTokens /  pioneers.length );
                    emit Transfer(poolAddress, rankedHolders[i], pioneersTokens /  pioneers.length);
                }
                
                if(i >= (20 * rankedHolders.length)/100 ){
                    balances[rankedHolders[i]] = balances[rankedHolders[i]].add( top20Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top20Tokens );
                    emit Transfer(poolAddress, rankedHolders[i], top20Tokens);
                    
                }
                else if(i >= (50 * rankedHolders.length)/100 ){
                    balances[rankedHolders[i]] = balances[rankedHolders[i]].add( top50Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top50Tokens );
                    emit Transfer(poolAddress, rankedHolders[i], top50Tokens);
                }
                else{
                    balances[rankedHolders[i]] = balances[rankedHolders[i]].add( top100Tokens );
                    balances[poolAddress] =  balances[ poolAddress ].sub( top100Tokens );
                    emit Transfer(poolAddress, rankedHolders[i], top100Tokens);
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
    
    function burn(uint256 amount) public onlyOwner{
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
    }
    
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}
