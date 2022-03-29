// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bank {

    constructor(){
        admin = payable(msg.sender);
    }

    receive() external payable {}

    struct Clients{
        string name;
        address payable account;
        bool isClient;
        string imageHash;
        string ipfsInfo;
    }

    mapping(address => Clients) bank_clients;
    mapping(address => bool) debt_clients;
    mapping(address => uint) debt_value;
    mapping(address => uint) amount_paid_back;
    mapping(address => uint) amount_user_can_loan;

    address payable public admin;
    
    function addClient(string calldata _name) public {
        require(msg.sender != admin, "Owner can not be a client");
        Clients memory client = Clients(_name, payable(msg.sender), false, "null", "null");
        bank_clients[msg.sender] = client;
    }

    function deleteClient(address payable _address) external {
        require(msg.sender == admin, "Not the owner!");
        delete bank_clients[_address];
    }

    function KYC(string calldata _imageHash, string calldata _ipfsInfo) public{ //tentar fazer os dados ficarem encriptados quando passado pra blockchain
        require(bank_clients[msg.sender].account != address(0), "Account do not exist!");
        require(bank_clients[msg.sender].isClient == false, "Account is already verified!");
        bank_clients[msg.sender].imageHash = _imageHash;
        bank_clients[msg.sender].ipfsInfo = _ipfsInfo;
    }

    function verifiedClient(address payable _address) external {
        require(msg.sender == admin, "Not the owner!");
        bank_clients[_address].isClient = true;
        amount_user_can_loan[_address] = 1 ether;
    }
    function setInDebt(uint _value) internal {
        debt_clients[msg.sender] = true;
        debt_value[msg.sender] = _value;
    }

    function getLoan(uint _amount) public payable returns(bool){
        require(_amount != 0, "Amount can not be zero");
        require(msg.sender == payable(msg.sender), "Address must be payable");
        require(bank_clients[msg.sender].isClient == true, "Must be a verified client");
        require(debt_clients[msg.sender] == false, "Your current account is in debt");
        require(amount_user_can_loan[msg.sender] >= _amount, "You can not loan this amout");
        uint total_balance = address(this).balance;
        require(total_balance > _amount, "Sorry, we don't have this money to loan");
        uint amount_in_wei = (_amount*1000000000000000000);
        payable(msg.sender).transfer(amount_in_wei);
        debt_clients[msg.sender] = true;
        debt_value[msg.sender] = _amount;
        return true;
    }
}
