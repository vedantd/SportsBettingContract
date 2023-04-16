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


    // ==========================BET HELPERS==========================

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
    
    function _getWinningTeam(bytes32 _matchId) public view returns(int8 winner){
        (,,,,,,winner)=CricketOracle.getMatch(_matchId);
        return winner;
    }
}