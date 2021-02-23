approvepragma solidity 0.5.6;

import "./ERC721.sol";
import "./ERC721TokenReceiver.sol";
import "../math/safe-math.sol";
import "../utils/SupportsInterface.sol";
import "../utils/AddressUtils.sol";

/**
 * 发布ERC-721不可替代令牌标准。
 * 转账，修改所有者之类的，查询之类的（erc721的所有方法）
 */
contract NFToken is
  ERC721,
  SupportsInterface
{
  using SafeMath for uint256;
  using AddressUtils for address;

  /**
   * 可以接收NEFT的智能合约的魔术值。
   * Equal to: bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")).
   */
  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  /**
   * 从NFT ID到拥有它的地址的映射。
   */
  mapping (uint256 => address) internal idToOwner;

    /**
    * 设置ID到期时间
    */
  mapping (uint256 => uint256) internal idExpireDate;
  /**
   * 从NFT ID映射到批准的地址。
   */
  mapping (uint256 => address) internal idToApproval;

   /**
   * 从所有者地址到其令牌计数的映射。
   */
  mapping (address => uint256) private ownerToNFTokenCount;

  /**
   * 从所有者地址到操作员地址的映射。
   */
  mapping (address => mapping (address => bool)) internal ownerToOperators;

  /**
   * 当任何NFT的所有权通过任何机制更改时发出。 当创建NFT（`from` == 0）并销毁（`to` == 0）时，此事件发出。 例外：在合同创建期间，可以创建和分配任意数量的NFT，而不会产生转让。 在进行任何传输时，该NFT的批准地址（如果有）都将重设为无。
   * _from NFT的发送者（如果地址为零地址，则表示令牌创建）。
   * NFT的接收者（如果地址为零地址，则表示令牌被破坏）。
   * _tokenId 已转让的NFT。
   */
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  /**
   * 在更改或重新确认NFT的批准地址时发出。 零地址表示没有批准的地址。 发出“转移”事件时，这还表示该NFT的批准地址（如果有）被重置为“无”。
   *  _owner NFT的所有者.
   *  _approved 批准的地址.
   *  _tokenId 批准的token.
   */
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  /**
   * 在为所有者启用或禁用操作员时发出。 运营商可以管理所有者的所有NFT。
   *  _owner NFT的所有者.
   *  _operator 运营商地址.
   *  _approved 运营商权限的状态（如果授予运营商权限，则为true；如果被撤消，则为false）
   */
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  /**
   * 确保msg.sender是指定NFT的所有者或运营商。
   *  _tokenId 要验证的NFT的ID。
   */
  modifier canOperate(
    uint256 _tokenId
  ) 
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender]);
    _;
  }

  /**
   * 确保允许msg.sender传输NFT。
   *  _tokenId 要转移的NFT的ID。
   */
  modifier canTransfer(
    uint256 _tokenId
  ) 
  {
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[tokenOwner][msg.sender]
    );
    _;
  }

  /**
   * 确保_tokenId是有效的令牌。
   *  _tokenId 要验证的NFT的ID。
   */
  modifier validNFToken(
    uint256 _tokenId
  )
  {
    require(idToOwner[_tokenId] != address(0));
    _;
  }

  /**
   * 创建token.
   */
  constructor()
    public
  {
    supportedInterfaces[0x80ac58cd] = true; // ERC721
  }

  /**
   * 将NFT的所有权从一个地址转移到另一个地址。 此功能可以更改为应付帐款。
   * msg.sender`是该NFT的当前所有者，授权运营商或批准地址，否则抛出
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
  {
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /**
   * 转账 跟上面的功能一样，只不过没有data
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
  {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * 功能跟上面差不多
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from);
    require(_to != address(0));

    _transfer(_to, _tokenId);
  }

  /**
   * 设置或确认NFT的批准地址。 此功能可以更改为应付款.
   * 零地址表示没有批准的地址。 除非`msg.sender`是当前NFT所有者或当前所有者的授权运营商，否则抛出。
   * @param _approved Address to be approved for the given NFT ID.
   * @param _tokenId ID of the token to be approved.
   */
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    canOperate(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(_approved != tokenOwner);

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  /**
   *  启用或禁用对第三方（“操作员”）管理“ msg.sender”所有资产的批准。 它还会发出ApprovalForAll事件。
   * @notice This works even if sender doesn't own any tokens at the time.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operators is approved, false to revoke approval.
   */
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
  {
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /**
   * 返回地址拥有id的数量
   * @param _owner Address for whom to query the balance.
   * @return Balance of _owner.
   */
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256)
  {
    require(_owner != address(0));
    return _getOwnerNFTCount(_owner);
  }

  /**
   * 返回id所有者的地址。 分配给零地址的NFT被认为是无效的，有关它们的查询也会抛出异常。
   * @param _tokenId The identifier for an NFT.
   * @return Address of _tokenId owner.
   */
  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address _owner)
  {
    _owner = idToOwner[_tokenId];
    require(_owner != address(0));
  }

  /**
   * 获取单个id的批准地址。
   * 如果`_tokenId`不是有效的NFT，则抛出该异常
   * @param _tokenId ID of the NFT to query the approval of.
   * @return Address that _tokenId is approved for. 
   */
  function getApproved(
    uint256 _tokenId
  )
    external
    view
    validNFToken(_tokenId)
    returns (address)
  {
    return idToApproval[_tokenId];
  }

  /**
   *  检查“ _operator”是否是“ _owner”的认可运营商。
   * @param _owner The address that owns the NFTs.
   * @param _operator The address that acts on behalf of the owner.
   * @return True if approved for all, false otherwise.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool)
  {
    return ownerToOperators[_owner][_operator];
  }

  /**
   * 实际执行转移的方法。
   * @notice Does NO checks.
   * @param _to Address of a new owner.
   * @param _tokenId The NFT that is being transferred.
   */
  function _transfer(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    address from = idToOwner[_tokenId];
    _clearApproval(_tokenId);

    _removeNFToken(from, _tokenId);
    _addNFToken(_to, _tokenId);

    emit Transfer(from, _to, _tokenId);
  }
   
  /**
   *  铸造新的token。
   * @notice This is an internal function which should be called from user-implemented external
   * mint function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   */
  function _mint( address _to, uint256 _tokenId ) internal {
    require(_to != address(0));
    require(idToOwner[_tokenId] == address(0));

    _addNFToken(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);
  }

    function _zhuan(
        address _from,
        address _to,
        uint256 _tokenId
    )
    internal
    {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

  /**
   * 刻录token。（不太明白作用）
   * @notice This is an internal function which should be called from user-implemented external burn
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation. Also, note that this burn implementation allows the minter to re-mint a burned
   * NFT.
   * @param _tokenId ID of the NFT to be burned.
   */
  function _burn(
    uint256 _tokenId
  )
    internal
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFToken(tokenOwner, _tokenId);
    emit Transfer(tokenOwner, address(0), _tokenId);
  }

  /**
   * 从所有者中删除id。
   * 请谨慎使用和覆盖此功能。 错误使用会造成严重后果。
   * @param _from Address from wich we want to remove the NFT.
   * @param _tokenId Which NFT we want to remove.
   */
  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
  {
    require(idToOwner[_tokenId] == _from);
    ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
    delete idToOwner[_tokenId];
  }

  /**
   * 向所有者分配新的NFT。
   * @notice Use and override this function with caution. Wrong usage can have serious consequences.
   * @param _to Address to wich we want to add the NFT.
   * @param _tokenId Which NFT we want to add.
   */
  function _addNFToken(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    require(idToOwner[_tokenId] == address(0));

    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to].add(1);
  }

  /**
   * 帮助程序函数，用于获取所有者的NFT计数。 覆盖可枚举的扩展名以消除所有者nft计数的双重存储（气体优化）时，需要使用此功能。不明白，待测试
   * @param _owner Address for whom to query the count.
   * @return Number of _owner NFTs.
   */
  function _getOwnerNFTCount(
    address _owner
  )
    internal
    view
    returns (uint256)
  {
    return ownerToNFTokenCount[_owner];
  }

  /**
   * 实际执行safeTransferFrom。
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    private
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from);
    require(_to != address(0));

    _transfer(_to, _tokenId);

    if (_to.isContract()) 
    {
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED);
    }
  }

  /** 
   * 清除给定NFT ID的当前批准。
   * @param _tokenId ID of the NFT to be transferred.
   */
  function _clearApproval(
    uint256 _tokenId
  )
    private
  {
    if (idToApproval[_tokenId] != address(0))
    {
      delete idToApproval[_tokenId];
    }
  }

}
