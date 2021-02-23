pragma solidity 0.5.6;

/**
 * ERC-721不可替代令牌标准的可选元数据扩展。
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721Metadata
{

  /**
   * 返回此合同中721名字。
   * @return Representing name. 
   */
  function name() external view returns (string memory _name);

  /**
   * 返回此合同中721的缩写名称。
   * @return Representing symbol. 
   */
  function symbol()
    external
    view
    returns (string memory _symbol);

  /**
   * 返回给定资产的唯一统一资源标识符（URI）。 如果_tokenId不是有效的NFT则抛出该异常。 URI在RFC3986中定义。 URI可能指向符合“ ERC721元数据JSON架构”的JSON文件。
   */
  function tokenURI(uint256 _tokenId)
    external
    view
    returns (string memory);

}
