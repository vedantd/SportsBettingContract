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


    /// @notice for testing; tests that the Cricket oracle is callable 
    /// @return true if connection successful 
    function testOracleConnection() public view returns (bool) {
        return CricketOracle.testConnection(); 
    }
}