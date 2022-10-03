pragma solidity 0.8.15;
pragma abicoder v2;

contract EthVault is ERC20{
    

    function deposit(address _to, uint256 _value) public returns (uint256 _shares) {
        //todo
        //calculate share
        //transfer amounts
        //mint share to user
    }

    function withdraw(address _to, uint256 _value) public returns (uint256 _amount){
        //todo
        //check amounts
        //burn shares
        //transfer amounts
    }

    function calculateShares(uint256 amounts) internal returns(uint256 _shares) {
        //todo
        //check amounts
        //calculate respective shares
    }
}