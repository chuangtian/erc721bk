pragma solidity 0.5.6;

import "./tokens/NFTokenMetadata.sol";
import "./tokens/NFTokenEnumerable.sol";
import "./ownership/ownable.sol";

/**
 * 发布合同
 */
contract MyArtSale is NFTokenEnumerable, NFTokenMetadata, Ownable {
    
  /**
   *  设置元数据扩展名“ name”和“ symbol”。
   */
  constructor() public {
    nftName = "Tian Chuang";
    nftSymbol = "TC"; 
  }

  /**
   * 创建新的token id
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   * @param _uri String representing RFC 3986 URI.
   */
  function mint( address _to, uint256 _tokenId, string calldata _uri ) external onlyOwner {
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
  }
  
  /**
   *刻录，我也不知道是干啥的，测试发现是把发个我的ID发给0x00000000000000000000000
   */
	function burn( uint256 _tokenId ) external {
		super._burn(_tokenId);

		if (bytes(idToUri[_tokenId]).length != 0){
		  delete idToUri[_tokenId];
		}
	}


    function removeNFToken( address _from, uint256 _tokenId ) external onlyOwner {
        super._removeNFToken(_from,_tokenId);
    }

    function safeTransferFromTest( address _from, address _to, uint256 _tokenId ) external {
        if(idExpireDate[_tokenId]==0 ||idExpireDate[_tokenId]>=now){
            super._safeTransferFrom(_from, _to, _tokenId);
        }else{
            _burn(_tokenId);
            if (bytes(idToUri[_tokenId]).length != 0){
                delete idToUri[_tokenId];
            }
        }
    }

}