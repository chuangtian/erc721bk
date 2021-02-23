pragma solidity 0.5.6;

/**
 * ERC-721界面，用于接受安全传输。
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721TokenReceiver
{

  /**
   * 处理NFT的收据。 ERC721智能合约在“转移”后在接收者上调用此功能。 该函数可以抛出以恢复和拒绝传输。 返回非魔幻值必须导致交易被还原。 除非抛出异常，否则返回`bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   * 合同地址总是消息发送者。 如果 钱包/经纪人/拍卖 应用程序接受安全转移，则必须实现钱包接口。
   * _operator调用“ safeTransferFrom”函数的地址。
   * _from先前拥有令牌的地址。
   * _tokenId正在传输的NFT标识符。
   * _data没有指定格式的其他数据。
   * @return Returns `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4);
    
}
