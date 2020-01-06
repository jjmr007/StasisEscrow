pragma solidity ^0.5.15;
//pragma experimental ABIEncoderV2;

contract registry {
    
    struct DataClient {
        
    DataBank    _Bank_Data;
    DataLocal   _Client_Data;
    DataFee     _Fee_Data;

    }
    
    struct DataBank {
        
        string ClientName;
        string Bank;
        string Account;
        
    }
    
    struct DataLocal {
        
        string PhoneNumb;
        string Country;
        string City;
        string AddRss;
        string PostCode;
        
    }
    
    struct DataFee {
        
        string fee;
        string Currency;
        string amount;
        
    }
    
    address payable public Owner;
    mapping (bytes4 => DataClient) internal Clients;
    
    
    constructor () public {
        
        Owner = msg.sender;
        
    }
    
    
    function SetClient (bytes4 A 
    , string memory _Client 
    , string memory _bank 
    , string memory _account 
    //, string memory _phone 
    //, string memory _countr
    //, string memory _city 
    //, string memory _curren
    //, string memory _adDrss 
    //, string memory _PCode     
    //, string[2] memory B 
    ) public {
        
        require (Owner == msg.sender);
        Clients[A]._Bank_Data.ClientName = _Client;
        Clients[A]._Bank_Data.Bank = _bank;
        Clients[A]._Bank_Data.Account = _account;
    //    Clients[A].PhoneNumb = _phone;
    //    Clients[A].Country = _countr;
    //    Clients[A].Currency = _curren;
    //    Clients[A].AddRss = _adDrss;
    //    Clients[A].PostCode = _PCode;
    //    Clients[A].Vendor = _vndr;
    //    Clients[A].fee = B[0];
    //    Clients[A].amount = B[1];

    }
    
    
    
    function SetLocal (bytes4 A 
    //, string memory _Client 
    //, string memory _bank 
    //, string memory _account 
    , string memory _phone 
    , string memory _countr
    , string memory _city 
    //, string memory _curren
    , string memory _adDrss 
    , string memory _PCode     
    //, string[2] memory B 
    ) public {
        
        require (Owner == msg.sender);
    //    Clients[A]._Bank_Data.ClientName = _Client;
    //    Clients[A]._Bank_Data.Bank = _bank;
    //    Clients[A]._Bank_Data.Account = _account;
        Clients[A]._Client_Data.PhoneNumb = _phone;
        Clients[A]._Client_Data.Country = _countr;
        Clients[A]._Client_Data.City = _city;
    //    Clients[A].Currency = _curren;
        Clients[A]._Client_Data.AddRss = _adDrss;
        Clients[A]._Client_Data.PostCode = _PCode;
    //    Clients[A].Vendor = _vndr;
    //    Clients[A].fee = B[0];
    //    Clients[A].amount = B[1];

    }
    
    function SetFee (bytes4 A 
    //, string memory _Client 
    //, string memory _bank 
    //, string memory _account 
    //, string memory _phone 
    //, string memory _countr
    //, string memory _city 
    , string memory _curren
    //, string memory _adDrss 
    //, string memory _PCode     
    , string memory _Fee
    , string memory _amount
    ) public {
        
        require (Owner == msg.sender);
    //    Clients[A]._Bank_Data.ClientName = _Client;
    //    Clients[A]._Bank_Data.Bank = _bank;
    //    Clients[A]._Bank_Data.Account = _account;
    //    Clients[A]._Client_Data.PhoneNumb = _phone;
    //    Clients[A]._Client_Data.Country = _countr;
    //    Clients[A]._Client_Data.City = _city;
        Clients[A]._Fee_Data.Currency = _curren;
    //    Clients[A]._Client_Data.AddRss = _adDrss;
    //    Clients[A]._Client_Data.PostCode = _PCode;
        Clients[A]._Fee_Data.fee = _Fee;
        Clients[A]._Fee_Data.amount = _amount;

    }
    
    function GetClient(bytes4 A) public view returns (
        string memory
        , string memory
        , string memory
        ) {
        
        string[3] memory X;

        X[0] = Clients[A]._Bank_Data.ClientName;
        X[1] = Clients[A]._Bank_Data.Bank;
        X[2] = Clients[A]._Bank_Data.Account;

        return (X[0], X[1], X[2]);
        
    }

        function GetLocal(bytes4 A) public view returns (
        string memory
        , string memory
        , string memory
        , string memory
        , string memory) {
        
        string[5] memory X;

        X[0] = Clients[A]._Client_Data.PhoneNumb;
        X[1] = Clients[A]._Client_Data.Country;
        X[2] = Clients[A]._Client_Data.City;
        X[3] = Clients[A]._Client_Data.AddRss;
        X[4] = Clients[A]._Client_Data.PostCode;

        return (X[0], X[1], X[2], X[3], X[4]);
        
    }

    function GetFee(bytes4 A) public view returns (
        string memory
        , string memory
        , string memory) {
        
        string[3] memory X;

        X[0] = Clients[A]._Fee_Data.Currency;
        X[1] = Clients[A]._Fee_Data.amount;
        X[2] = Clients[A]._Fee_Data.fee;
        
        return (X[0], X[1], X[2]);
        
    }

}

contract GenerateCode {
    
    function Code4 () public view returns (bytes4) {
        
        bytes32 A = sha256(abi.encodePacked(block.number));
        return bytes4(uint32(uint256(A)));
        
    }
}
