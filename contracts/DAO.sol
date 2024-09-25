//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import"./Token.sol";

contract DAO {
    address owner;
    Token public token;
    uint256 public quorum;

    struct Proposal{
        uint256 id;
        string name;
        uint256 amount;
        address payable recipient;
        uint256 votes;
        bool finalize;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event Propose(
        uint id,
        uint256 amount,
        address recipient,
        address creator
    );

    event Vote(uint256 id, address investor);

    constructor(Token _token, uint256 _quorum){
        owner = msg.sender;
        token = _token;
        quorum = _quorum;
    }

    //allow contract to recieve ether
    receive () external payable {}

    modifier onlyInvestor() {
        require(
            token.balanceOf(msg.sender) > 0, 
            "must be token holder"
        );
        _;
    }

    function createProposal
    (
        string memory _name,
        uint256 _amount,
        address payable _recipient
    ) external onlyInvestor 
    {
        require(address(this).balance >= _amount);

        proposalCount++;

        proposals[proposalCount] = Proposal(
            proposalCount, 
            _name, 
            _amount, 
            _recipient, 
            0, 
            false
        );

        emit Propose(
            proposalCount, 
            _amount, 
            _recipient, 
            msg.sender
            );

    } 

    mapping ( address => mapping (uint256 => bool)) votes;

    function vote(uint256 _id) external onlyInvestor {
        //fetch proposal from mapping by id 
        Proposal storage proposal = proposals[_id];

        //dont let investors vote twice
        require(!votes[msg.sender][_id], "already voted");

        //update votes
        proposal.votes += token.balanceOf(msg.sender); 

        //track that user has voted
        votes[msg.sender][_id] = true;

        //emit event 
        emit Vote(_id, msg.sender);
    }



















}
