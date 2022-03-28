// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bank {

    constructor(){
        admin = payable(msg.sender);
    }

    struct Clients{
        string name;
        address payable account;
        bool isClient;
        string imageHash;
        string ipfsInfo;
    }

    mapping(address => Clients) bank_clients;
    mapping(uint => address payable) debt_clients;

    address payable public admin;
    address payable[] internal inDebt;
    
    function addClient(string calldata _name) public {
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
    }
}
