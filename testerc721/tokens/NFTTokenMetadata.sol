pragma solidity 0.5.6;

import "./NFToken.sol";
import "./ERC721Metadata.sol";

/**
 * ERC-721不可替代令牌标准的可选元数据实现。（名字，简称，等等）
 */
contract NFTokenMetadata is
  NFToken,
  ERC721Metadata
{

  /**
   * 名字
   */
  string internal nftName;

  /**
   * 简称
   */
  string internal nftSymbol;

  /**
   *  ID映射到元数据uri。
   */
  mapping (uint256 => string) internal idToUri;

  /**
   * @dev Contract constructor.
   *  实施此合同时，请不要忘记设置nftName和nftSymbol。
   */
  constructor()
    public
  {
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
  }

  /**
   * 返回token名字
   * @return Representing name. 
   */
  function name()
    external
    view
    returns (string memory _name)
  {
    _name = nftName;
  }

  /**
   * 简称
   * @return Representing symbol. 
   */
  function symbol()
    external
    view
    returns (string memory _symbol)
  {
    _symbol = nftSymbol;
  }

  /**
   * 给定NFT的不同URI（RFC 3986）
   * @param _tokenId Id for which we want uri.
   * @return URI of _tokenId.
   */
  function tokenURI(
    uint256 _tokenId
  )
    external
    view
    validNFToken(_tokenId)
    returns (string memory)
  {
    return idToUri[_tokenId];
  }

  /**
   * 刻录NFT。（不明白一会测试一下）
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

    if (bytes(idToUri[_tokenId]).length != 0)
    {
      delete idToUri[_tokenId];
    }
  }

  /**
   * 为给定的NFT ID设置唯一的URI（RFC 3986）。
   * @notice This is an internal function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _tokenId Id for which we want uri.
   * @param _uri String representing RFC 3986 URI.
   */
  function _setTokenUri(
    uint256 _tokenId,
    string memory _uri
  )
    internal
    validNFToken(_tokenId)
  {
    idToUri[_tokenId] = _uri;
  }

}
