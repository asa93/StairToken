
//override Number functions to stick to SafeMath
Number.prototype.add = function(num){ 
				if(this+num<0) throw "Sum is negative"
				return this+num
};
Number.prototype.sub = function(num){ 
				if(this-num<0) throw "Sum is negative"
				return this-num
};
Number.prototype.mul = function(num){ 
				return Math.floor(this*num)
};
Number.prototype.div = function(num){ 
				if(num==0) throw "Divide by zero."
        else return Math.floor(this/num)
};

class BalanceTracker {
	
  constructor(length){
  	this.trees = []
  	for(let i=0; i<length;i++){
    	this.trees.push(i)
    }
  }
  
//generate balance from ranking because it's easier for testing
// in practice it is the opposite
  generateBalance(){

    let balances = []
    for(let i=0; i<this.trees.length; i++){
    	balances.push(1000-i*10)
    }
    return balances
  }
  getUserAtRank(index){
  	if(this.trees[index-1]===undefined) throw "No user of given index " + index
    return this.trees[index-1]
  }
  
}
let balanceTracker = new BalanceTracker(5);
let balances = balanceTracker.generateBalance();

console.log(balances, balanceTracker.trees)




function poolDispatch(eligibleHolders, poolBalance, teamBalance, balances, balanceTracker ){
       	
        if(eligibleHolders !== Math.floor(eligibleHolders)) throw "eligibleHolders should be integer."
        const teamShare = 40;
     
        let teamTokens = poolBalance*teamShare/100;
        let holderTokens = poolBalance - teamTokens;
        
        teamBalance =  teamBalance.add(teamTokens);
        poolBalance =  poolBalance.sub( teamTokens );
        
        let top20Tokens=0;
        let top50Tokens=0;
        let top100Tokens=0;
        
        //count of occurrences solely for TEST purposes
        let top20count = 0;
        let top50count = 0;
        let top100count=0;
             
        if(eligibleHolders == 0) return;
        
        else if(eligibleHolders == 1){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens);
            poolbalance = poolbalance.sub(holderTokens);
        }
        
        else if(eligibleHolders ==2){
            balances[balanceTracker.getUserAtRank(1)] = balances[balanceTracker.getUserAtRank(1)].add(holderTokens.div(2));
            balances[balanceTracker.getUserAtRank(2)] = balances[balanceTracker.getUserAtRank(2)].add(holderTokens.div(2));
            poolbalance = poolBalance.sub(holderTokens);
        
        }
        else{
             //uint256 pioneersTokens= holderTokens*2/100;
            // holderTokens = holderTokens.sub(pioneersTokens);
             
             //Calculate token alocation
             top20Tokens=0;
             top50Tokens=0;
             top100Tokens=0;

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
                top100Tokens = (holderTokens.mul(18).div(100)).div(eligibleHolders.sub(eligibleHolders.mul(30).div(100)).sub(eligibleHolders.mul(20).div(100))); 
            
             
             
            for (let i=1; i<=eligibleHolders; i++) {
                 
           				
                
                if(i <= (eligibleHolders.mul(20)).div(100) ){
                    top20count++; //test
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top20Tokens );
                    poolBalance =  poolBalance.sub( top20Tokens );

                    
                }
                else if(i <= (eligibleHolders.mul(20)).div(100).add( (eligibleHolders.mul(30)).div(100)) ){
										top50count++; //test
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top50Tokens );
                    poolBalance =  poolBalance.sub( top50Tokens );

                }
                else{
										top100count++;//test
                    balances[balanceTracker.getUserAtRank(i)] = balances[balanceTracker.getUserAtRank(i)].add( top100Tokens );
                    poolBalance =  poolBalance.sub( top100Tokens );
                }
                
                
 
                     
            }
        }
        
        return {
        		finalPoolBalance : poolBalance,
            holderTokens : holderTokens,
            top20Tokens : top20Tokens,
            top20count: top20count,
            top50Tokens : top50Tokens,
            top50count: top50count,
            top100Tokens : top100Tokens,
            top100count : top100count,
            
        }

        
    }

console.log("/////// before poolDispatch", "balances:",balances
							, "\ntree:",balanceTracker.trees
              , "\npoolBalance:",100
              , "\nteamBalance:", 10
              , "\neleigibleHolders:", balances.length)
let result =poolDispatch(balances.length, 100, 10, balances, balanceTracker)

 
 console.log(result)