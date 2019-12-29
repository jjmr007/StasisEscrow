pragma solidity ^0.5.15;

/**
 * 
 * The main purpose is test Gas consumption
 * for a change of state of a map from bytes32 
 * to an struct with several kind of data words
 * 
 * the reference is the change of state of
 * an ERC20 token with the transfer functions
 * which makes two changes of the state (SSTORE)
 * one for balances[msg.sender] and the other
 * for balances[to]; it is from 40.000 to
 * 60.000 Gas units
 * 
 * This contract tests a simil transfer function
 * Gas consumption and compares it with
 * -> changing a single word (uint256 variable)
 * -> changing once the state of a map => struct
 * with one, two and three types of word data
 * 
 */ 

contract TokenTestGas {
    
    /**
     * these are the reference state variables
     * we're going to compare with
     */
    
    mapping(address => uint256) public balances;
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor () public {
        
        // to avoid an exception
        balances[msg.sender] = 100000000;
        
    }
    
    /**
     * this function takes around 51k Gas
     */ 
    function transfer(address _to, uint256 _value) public returns (bool) {
        
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    } 
    
 }
   
   
   
   
   
   
   
contract EscrowTestGas {
    
    /**
     * Now we set another kind of state
     * a struct and a map
     * 
     */
     
    struct  Escrow {
/**
 * Under this struct model
 * transaction createEscrow
 * spends around 49k Gas_un
 * 
        bool    exists;
        uint32  cancelling;
        uint128 FeesSpent;
  */

/**
 * Under this other struct model
 * transaction createEscrow
 * spends around 87k Gas_un
 */   
        bytes32 exists;
        bytes32 cacelling;
        bytes32 FeesSpent;
        
    }

    mapping (bytes => Escrow) public Diferente;
    
    mapping (bytes32 => Escrow) public escrows;
    
    event Created(bytes32 indexed _tradeHash);
    
    /**
     * this is a consult function in order 
     * to be able to inspect the map
     */
    function TestHash(
    
        address _seller,
        address _buyer,
        uint256 _value,
        uint32 _paymentWindowInSeconds

        ) pure public returns (bytes32) {
            
            return keccak256(abi.encodePacked(_seller, _buyer, _value, _paymentWindowInSeconds));
        }
        
    function conCatenate(bytes32 x, bytes32 y) pure public returns (bytes memory) {
        
        return abi.encodePacked(x, y);
        
    }

    function createEscrow(
    
        address _seller,
        address _buyer,
        uint256 _value,
        uint32 _paymentWindowInSeconds

        )
        
        /* 
        which changes may be required to do this 
        with the Token instead of ether?
        NOT POSSIBLE:
        To make in a single transaction 
        a state change and a token transfer 
        It requires at least an "approve" extra 
        transaction 
        */
        
        payable 
        external {
            
        /*
        bytes32 _tradeHash = keccak256(abi.encodePacked(_seller, _buyer, _value, _paymentWindowInSeconds));
        */
        bytes32 X = keccak256(abi.encodePacked(_seller, _buyer, _value, _paymentWindowInSeconds));
        bytes32 Y = keccak256(abi.encodePacked(_seller, _buyer, _value + 10, _paymentWindowInSeconds + 100));
        bytes memory _tradeHash = conCatenate(X, Y);
        
        require(Diferente[_tradeHash].exists != bytes32(uint256(1)), "Trade already exists");
        // require(escrows[_tradeHash].exists != bytes32(uint256(1)), "Trade already exists");
        
        uint32 _sellerCanCancelAfter = _paymentWindowInSeconds == 0
            ? 1
            : uint32(block.timestamp) + _paymentWindowInSeconds;
            
        bytes32 A = bytes32(uint256(_sellerCanCancelAfter));
        bytes32 B = bytes32(uint256(100));

        Diferente[_tradeHash] = Escrow(bytes32(uint256(1)), A, B);
        //escrows[_tradeHash] = Escrow(bytes32(uint256(1)), A, B);
        /*
        TokenTestGas _C;
        _C.transferFrom(msg.sender, address(this), _value);
        */
        emit Created(X);
        

        }
    
    
    
    
    
    /**
     * Finally a function that makes only a state changes
     * and do an internal transfer
     * The first execution of transferMinusFees takes around 51k Gas
     * second time it is cheaper: around 37k Gas
     * 
     */
     
    uint256 public feesAvailableForWithdraw;
    
    function transferMinusFees(
        address payable _to,
        uint256 _value,
        uint128 _totalGasFeesSpentByRelayer,
        uint16 _fee
    ) public {
        
        uint256 _totalFees = (_value * _fee / 10000) + _totalGasFeesSpentByRelayer;
        
        // Prevent underflow
        if(_value - _totalFees > _value) {
            return;
        }
        
        // Add fees to the pot for localethereum to withdraw
        
        // RELEVANT CHANGE OF STATE

        feesAvailableForWithdraw += _totalFees;

        // INTERNAL TRANSFER TRANSACTION

        _to.transfer(_value - _totalFees);
        
        /*
        TokenTestGas _C;
        uint256 A = _value - _totalFees;
        _C.transfer(_to, A);
        */
        
    }    
     

}
