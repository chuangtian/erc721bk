pragma solidity 0.5.6;

/**
 * @dev 合同具有所有者地址，并提供基本的授权控制功能
 * 简化了用户权限的实现
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable
{
  
  /**
   * @dev 错误常量
   */
  string public constant NOT_OWNER = "018001";
  string public constant ZERO_ADDRESS = "018002";

  /**
   * @dev 合同拥有者地址.
   */
  address public owner;

  /**
   * @dev更改所有者时触发的事件。
   * @param previousOwner先前所有者的地址。
   * @param newOwner新所有者的地址。
   */
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev 将合同所有者的地址设置为.
   */
  constructor()
    public
  {
    owner = msg.sender;
  }

  /**
   * @dev 所有外来的账户都抛出异常.
   */
  modifier onlyOwner()
  {
    require(msg.sender == owner, NOT_OWNER);
    _;
  }

  /**
   * @dev 将合同所有权转给新的地址
   */
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {
    require(_newOwner != address(0), ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}
