pragma solidity 0.8.15;
pragma abicoder v2;

contract LbStorage{

    address owner;
    address impl;


     constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    mapping (address => mapping (address => uint256)) amounts;
    mapping(address => uint256) assetSupply;


    function setImplementation(address _impl) external onlyOwner {
        require(_impl != address(0), "Invalid Address");
        impl = _impl;
    }

    //both functions just for testing
    function setter(address asset, uint256 amount) external {
        amounts[msg.sender][asset] = amount;
    }

    function getter(address asset) external view returns(uint256 amount){
        amount = amounts[msg.sender][asset];
    }


}