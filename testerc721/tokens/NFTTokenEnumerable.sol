pragma solidity 0.5.6;

import "./NFToken.sol";
import "./ERC721Enumerable.sol";

/**
 *  ERC-721不可替代令牌标准的可选枚举实现。（返回id总数，给id加索引，之类的）
 */
contract NFTokenEnumerable is
  NFToken,
  ERC721Enumerable
{

  /**
   * 所有token ID的数组。
   */
  uint256[] internal tokens;

  /**
   * 从令牌ID映射到全局令牌数组中的索引。
   */
  mapping(uint256 => uint256) internal idToIndex;

  /**
   * 从所有者到拥有的NFT ID列表的映射。
   */
  mapping(address => uint256[]) internal ownerToIds;

  /**
   *Token ID映射到所有者令牌列表中的索引。
   */
  mapping(uint256 => uint256) internal idToOwnerIndex;

  /**
   * @dev Contract constructor.
   */
  constructor()
    public
  {
    supportedInterfaces[0x780e9d63] = true; // ERC721Enumerable
  }

  /**
   * 返回所有现有NFToken的计数。
   * @return Total supply of NFTs.
   */
  function totalSupply()
    external
    view
    returns (uint256)
  {
    return tokens.length;
  }

  /**
   * 通过其索引返回NFT ID。
   * @param _index A counter less than `totalSupply()`.
   * @return Token id.
   */
  function tokenByIndex(
    uint256 _index
  )
    external
    view
    returns (uint256)
  {
    require(_index < tokens.length);
    return tokens[_index];
  }

  /**
   * 从所有者令牌列表中返回第n个NFT ID。
   * @param _owner Token owner's address.
   * @param _index Index number representing n-th token in owner's list of tokens.
   * @return Token id.
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    external
    view
    returns (uint256)
  {
    require(_index < ownerToIds[_owner].length);
    return ownerToIds[_owner][_index];
  }

  /**
   * @dev 铸造新的NFT。
   * @notice This is an internal function which should be called from user-implemented external
   * mint function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   */
  function _mint(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    super._mint(_to, _tokenId);
    uint256 length = tokens.push(_tokenId);
    idToIndex[_tokenId] = length - 1;
  }
    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    internal
    {
        super._zhuan(_from, _to,_tokenId);
    }


    /**
     * 刻录NFT。(不明白)
     * @notice This is an internal function which should be called from user-implemented external
     * burn function. Its purpose is to show and properly initialize data structures when using this
     * implementation. Also, note that this burn implementation allows the minter to re-mint a burned
     * NFT.
     * @param _tokenId ID of the NFT to be burned.
     */
  function _burn(
    uint256 _tokenId
  )
    internal
  {
    super._burn(_tokenId);

    uint256 tokenIndex = idToIndex[_tokenId];
    uint256 lastTokenIndex = tokens.length - 1;
    uint256 lastToken = tokens[lastTokenIndex];

    tokens[tokenIndex] = lastToken;

    tokens.length--;
    // This wastes gas if you are burning the last token but saves a little gas if you are not. 
    idToIndex[lastToken] = tokenIndex;
    idToIndex[_tokenId] = 0;
  }

  /**
   * @dev删除
   * @notice Use and override this function with caution. Wrong usage can have serious consequences.
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
    delete idToOwner[_tokenId];

    uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
    uint256 lastTokenIndex = ownerToIds[_from].length - 1;

    if (lastTokenIndex != tokenToRemoveIndex)
    {
      uint256 lastToken = ownerToIds[_from][lastTokenIndex];
      ownerToIds[_from][tokenToRemoveIndex] = lastToken;
      idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    }

    ownerToIds[_from].length--;
    tokens.length--;
  }

  /**
   * Assignes a new NFT to an address.
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

    uint256 length = ownerToIds[_to].push(_tokenId);
    idToOwnerIndex[_tokenId] = length - 1;
  }

  /**
   * 帮助程序函数，用于获取所有者的NFT计数。 这对于覆盖可枚举是必需的（不明白，待测试）
   * extension to remove double storage(gas optimization) of owner nft count.
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
    return ownerToIds[_owner].length;
  }
}
