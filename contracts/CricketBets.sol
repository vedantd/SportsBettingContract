// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./OracleInterface.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


/// @title CricketBets
/// @author Vedant Dalvi
/// @notice Takes bets and handles payouts for Cricket matches 
contract CricketBets is Ownable {
        using SafeMath for uint256;
   
    address payable public Owner;
    //mappings 
    mapping(address => Bet[]) private userToBets;
    mapping(bytes32 => Bet[]) private matchToBets;
    address internal CricketOracleAddr = 0x720aaF13cE810869b1Ef83c1215A09431C2E252b;
    OracleInterface internal CricketOracle = OracleInterface(CricketOracleAddr); 

    //constants    
    struct Bet {
        address user;
        bytes32 matchId;
        uint amount; 
        int8 chosenWinner; 
    }

    constructor ()  { 
       
    }

    // ==========================ORACLE FUNCTIONS==========================
    /// @notice sets the address of the Cricket oracle being used 
    /// @return bool of connection success
    function setOracleAddress(address _oracleAddress) external onlyOwner returns (bool) {
        CricketOracleAddr = _oracleAddress;
        CricketOracle = OracleInterface(CricketOracleAddr); 
        return CricketOracle.testConnection();
    }
    /// @notice gets the address of the Cricket oracle being used 
    /// @return the address of the currently set oracle 
    function getOracleAddress() external view returns (address) {
        return CricketOracleAddr;
    }
    /// @notice for testing; tests that the Cricket oracle is callable 
    /// @return true if connection successful 
    function testOracleConnection() public view returns (bool) {
        return CricketOracle.testConnection(); 
    }


    // ==========================ORACLE BET HELPERS==========================

    /// @notice gets a list ids of all currently bettable matches
    /// @return array of match ids 
    function getBettableMatches() public view returns (bytes32[] memory) {
        return CricketOracle.getPendingMatches(); 
    }

    /// @notice returns the full data of the specified match 
    /// @param _matchId the id of the desired match
    
    function getMatch(bytes32 _matchId) public view returns (
        bytes32 id,
        string memory name, 
        string memory participants,
        uint8 participantCount,
        uint date, 
        OracleInterface.MatchOutcome outcome, 
        int8 winner) { 

        return CricketOracle.getMatch(_matchId); 
    }

    /// @notice returns the recented appended match to the oracle
    function getMostRecentMatch() public view returns (
        bytes32 id,
        string memory name, 
        string memory participants,
        uint participantCount, 
        uint date, 
        OracleInterface.MatchOutcome outcome, 
        int8 winner) { 

        return CricketOracle.getMostRecentMatch(true); 
    }

    /// @notice returns the winner of the specified match (0 or 1)
    function _getWinningTeam(bytes32 _matchId) public view returns(int8 winner){
        (,,,,,,winner)=CricketOracle.getMatch(_matchId);
        return winner;
    }

    // ==========================WINNING SHARE HELPER FUNCTIONS==========================
    
    /// @notice returns the total amount in pot on the winning side of bet
    function _getWinnersPotAmount  (bytes32 _matchId) public view returns(uint256) {
        Bet[] storage bets1 = matchToBets[_matchId];
        int8 _winningTeam = _getWinningTeam(_matchId);
        uint256 sum;
        for (uint i=0; i<bets1.length; i++) {
            if(bets1[uint(i)].chosenWinner==_winningTeam){
                sum=sum+bets1[uint(i)].amount;
            }
        }
        return sum;
    }

    // @notice returns the total amount in pot on the losing side of bet
    function _getLosersPotAmount  (bytes32 _matchId) public view returns(uint256) {
        // chcek if outcomne is specifically decided
        Bet[] storage bets1 = matchToBets[_matchId];
        int8 _winningTeam = _getWinningTeam(_matchId);
        uint256 sum;
        for (uint i=0; i<bets1.length; i++) {
            if(bets1[uint(i)].chosenWinner!=_winningTeam){
                sum=sum+bets1[uint(i)].amount;
            }
            
        }
        return sum;
    }

    
    // ==========================BETTING FUNCTION==========================

    /// @notice places a non-rescindable bet on the given match 
    /// @param _matchId the id of the match on which to bet 
    /// @param _chosenWinner the index of the participant chosen as winner (0 or 1)
    function placeBet(bytes32 _matchId, int8 _chosenWinner) external  payable {

        require(CricketOracle.matchExists(_matchId), "Specified match not found"); 

        Bet[] storage bets = matchToBets[_matchId]; 
        bets = matchToBets[_matchId]; 
        bets.push(Bet(msg.sender, _matchId, msg.value, _chosenWinner)); 

        Bet[] storage userBets = userToBets[msg.sender];
        userBets = userToBets[msg.sender]; 
        userBets.push(Bet(msg.sender, _matchId, msg.value, _chosenWinner)); 
        
    }
}