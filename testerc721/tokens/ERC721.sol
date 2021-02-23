pragma solidity 0.5.6;

/**
 *  ERC-721 不可替代令牌标准. 
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721
{

  /**
   * 转移erc721的时候触发这个事件
   * 转移后，该NFT的批准地址（如果有）将重置为无
   */
  event Transfer(address indexed _from,address indexed _to,uint256 indexed _tokenId);

  /**
   * 修改721token批准人的时候会触发
   */
  event Approval(address indexed _owner,address indexed _approved,uint256 indexed _tokenId);

  /**
   * 合同创建者启用操作员或者禁用操作员。运营用户可以管理所有的721token
   */
  event ApprovalForAll(address indexed _owner,address indexed _operator,bool _approved);

  /**
   * 721token从一个地址转到另外一个地址
   * _from NFT的当前所有者。
   * _to新所有者。
   * _tokenId要传输的NFT。
   * _data没有指定格式的附加数据，通过调用_to发送。
   */
  function safeTransferFrom(address _from,address _to,uint256 _tokenId,bytes calldata _data) external;

  /**
   * 721token从一个地址转到另外一个地址，data为空
   */
  function _clearApproval(address _from,address _to,uint256 _tokenId) external;

  /**
  *除非`msg.sender`是此NFT的当前所有者，授权操作员或批准的地址。如果`_from`不是当前所有者，则抛出该异常。如果_to为零地址，则抛出该异常。 如果`_tokenId`不是有效的NFT，则抛出该异常。msg.sender需要确认to地址必须要能够接收，不然会永久丢失这个token
  */
  function transferFrom(address _from,address _to,uint256 _tokenId) external;

  /**
   *设置确认token的批准地址。0地址表示没有批准地址。
   *  _approved新批准的token地址。
   *  _tokenId要批准的token.
   */
  function approve(address _approved,uint256 _tokenId) external;

  /**
   * 启用或者禁用第三方管理
   * 注意合同必须允许每个所有者有多个运营商。
   *  _operator要添加到授权操作员集中的地址。
   *  _approved如果批准了操作员，则为True，否则为撤消批准
   */
  function setApprovalForAll(address _operator,bool _approved) external;

  /**
   * 返回“ _owner”拥有的NFT的数量。 分配给零地址的NFT被认为是无效的，并且此函数引发有关零地址的查询。
   *  _owner查询余额的地址。
   *  所有者的余额.
   */
  function balanceOf( address _owner) external view returns (uint256);

  /**
   * 返回NFT所有者的地址。 分配给零地址的NFT被认为是无效的，有关它们的查询也会抛出异常。
   *  _tokenId NFT的标识符。
   *  _tokenId所有者的地址。
   */
  function ownerOf( uint256 _tokenId) external view returns (address);
    
  /**
   *  获取单个NFT的批准地址。
   *  如果`_tokenId`不是有效的NFT，则抛出该异常。
   *  _tokenId查找要为其批准的地址的NFT
   *   _tokenId批准的地址。
   */
  function getApproved(uint256 _tokenId) external view returns (address);

  /**
     *如果`_operator`是`_owner`的批准运算符，则返回true，否则返回false。
     *  _owner拥有NFT的地址。
     *  _operator代表所有者的地址。
     * 如果全部批准，则为True，否则为false。
   */
  function isApprovedForAll(address _owner,address _operator) external view returns (bool);

}
