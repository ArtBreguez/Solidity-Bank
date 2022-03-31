// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/// @title Loan Bank simulator
/// @author Arthur Gonçalves Breguez
/// @notice User can get ether from contract and gis debts

contract Bank {

    /// @notice Require 5 ether to deploy the contract
    constructor() payable{
        require(msg.value == 5 ether, "Set the inicial balance of contract on 5 ether");
        admin = payable(msg.sender);
    }

    /// @notice Receive money from verified user who is in debt
    receive() external payable {
        require(debt_clients[msg.sender] == true, "You are not in debt");
        debt_value[msg.sender] -= msg.value;
        if(debt_value[msg.sender] == 0){
            debt_clients[msg.sender] = false;
        }
        emit LogDebtPayment(msg.sender, msg.value);
    }

    struct Clients{
        string name;
        address payable account;
        bool isClient;
    }

    mapping(address => Clients) bank_clients;
    mapping(address => bool) debt_clients;
    mapping(address => uint) debt_value;
    mapping(address => uint) amount_paid_back;
    mapping(address => uint) amount_user_can_loan;

    address payable public admin;
    
    // @notice Emit logs when user make a loan or pay his debts
    event LogNewLoan(address indexed _client, uint _amount);
    event LogDebtPayment(address indexed _client, uint _amount);

    /// @notice Retrieve the balance of contract
    function getContractBalance()public view returns(uint){
        require(msg.sender == admin, "Not the owner!");
        return address(this).balance;
    }

    /// @notice Retrieve the debt value of the client
    /// @param _address Client address who is in debt
    /// @return Client debt value
    function getClientDebtBalance(address _address) public view returns(uint){
        return debt_value[_address];
    }

    /// @notice Add an user to the bank system
    /// @param _name User name
    function addClient(string calldata _name) public {
        require(msg.sender != admin, "Owner can not be a client");
        require(bank_clients[msg.sender].account == address(0));
        Clients memory client = Clients(_name, payable(msg.sender), false);
        bank_clients[msg.sender] = client;
    }

    /// @notice Delete an user from the bank system
    function deleteClient(address payable _address) external {
        require(msg.sender == admin, "Not the owner!");
        delete bank_clients[_address];
    }

    /// @notice Makes the user eligible to borrow money from the contract
    /// @param _address Registered user address
    function verifiedClient(address payable _address) external {
        require(msg.sender == admin, "Not the owner!");
        bank_clients[_address].isClient = true;
        amount_user_can_loan[_address] = 1;
    }

    /// @notice Set client in bank debt list
    /// @param _value Debt value in wei 
    function setInDebt(uint _value) internal {
        debt_clients[msg.sender] = true;
        debt_value[msg.sender] = _value;
    }

    /// @notice Update how much user can borrow from the contract
    /// @param _address User address
    /// @param _new_amount User new borrow limit
    function updateAmountUserCanLoan(address _address, uint _new_amount) external {
        require(msg.sender == admin, "Not the owner!");
        amount_user_can_loan[_address] = _new_amount;
    }

    /// @notice Lend verified users ether
    /// @param _amount Amount of money user wants to borrow in ether
    /// @return bool True in case the transaction did well or false in case transcation fails
    function makeALoan(uint _amount) public payable returns(bool){
        require(_amount != 0, "Amount can not be zero");
        require(msg.sender == payable(msg.sender), "Address must be payable");
        require(bank_clients[msg.sender].isClient == true, "Must be a verified client");
        require(debt_clients[msg.sender] == false, "Your current account is in debt");
        require(amount_user_can_loan[msg.sender] >= _amount, "You can not loan this amout");
        uint total_balance = address(this).balance;
        require(total_balance > _amount, "Sorry, we don't have this money to loan");
        uint amount_in_wei = (_amount*1000000000000000000);
        setInDebt(amount_in_wei);
        payable(msg.sender).transfer(amount_in_wei);
        emit LogNewLoan(
            msg.sender,
            amount_in_wei
        );
        return true;
    }
}
