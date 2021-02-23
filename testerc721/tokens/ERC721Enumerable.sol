pragma solidity 0.5.6;

/**
 * ERC-721不可替代令牌标准的可选枚举扩展
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721Enumerable
{

  /**
   * 返回此合同跟踪的有效NFT的计数
   * @return NFT的总供应。
   */
  function totalSupply() external view returns (uint256);

  /**
   * 返回第_index个NFT的令牌标识符。 未指定排序顺序。
   * _index小于`totalSupply（）`的计数器。
   * @return Token id.
   */
  function tokenByIndex(uint256 _index ) external view returns (uint256);

  /**
   * 返回分配给_owner的第_index个NFT的令牌标识符。 未指定排序顺序。 如果`_index`>=`balanceOf（_owner）`或`_owner`是零地址，表示无效的NFT，则抛出该错误。
   * _owner我们对其拥有的NFT感兴趣的地址。
   * reindex一个小于`balance Of（_owner）`的计数器
   * @return Token id.
   */
  function tokenOfOwnerByIndex(address _owner,uint256 _index) external view returns (uint256);

}
