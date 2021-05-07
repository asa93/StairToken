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
