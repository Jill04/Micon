pragma solidity ^0.6.0;

import "./IERC1155Receiver.sol";
import "./ERC165.sol";


contract ERC1155Receiver is ERC165,IERC1155Receiver{
    constructor()public{
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
            );
    }
    
    function onERC1155Received(address ,address ,uint256 ,uint256 ,bytes memory )public override returns(bytes4){
      return this.onERC1155Received.selector;   
    }
    
     function onERC1155BatchReceived(address ,address ,uint256[] memory ,uint256[] memory ,bytes memory )public override returns(bytes4){
      return this.onERC1155BatchReceived.selector;   
    }
    
}
