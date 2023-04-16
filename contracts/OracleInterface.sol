// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

abstract contract OracleInterface {
    enum MatchOutcome {
        Pending,    //match has not been fought to decision
        Underway,   //match has started & is underway
        Draw,       //anything other than a clear winner (e.g. cancelled)
        Decided     //index of participant who is the winner 
    }
    mapping(bytes32 => uint) matchIdToIndex; 
   function getMatchOutcome(bytes32 _matchId) public virtual  view returns  (bool);

    function getPendingMatches() public virtual view returns (bytes32[] memory);

    function getAllMatches() public virtual view returns (bytes32[] memory);

    function matchExists(bytes32 _matchId) public virtual view returns (bool); 

    function getMatch(bytes32 _matchId) public virtual view returns (
        bytes32 id,
        string memory name , 
        string memory participants,
        uint8 participantCount,
        uint date, 
        MatchOutcome outcome, 
        int8 winner);

    function getMostRecentMatch(bool _pending) virtual public view returns (
        bytes32 id,
        string memory name, 
        string memory participants,
        uint participantCount,
        uint date, 
        MatchOutcome outcome, 
        int8 winner);

    function testConnection() public virtual pure returns (bool);

    function addTestData() public virtual; 
}
