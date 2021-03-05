pragma solidity ^0.6.0;

import "./IERC165.sol";

 abstract contract ERC165 is IERC165{
    
    bytes4 private constant interface_id = 0x01ffc9a7;
    
    mapping(bytes4 => bool)private supportedInterfaces;
    
    constructor()internal{
        //_registerInterface(interface_id);
    }
    
    function _registerInterface(bytes4 _interfaceId)internal virtual {
        require(_interfaceId != 0xffffffff,"Invalid interface id");
        supportedInterfaces[_interfaceId] = true;
    }
    
    function supportsInterface(bytes4 _interfaceId)public view override returns(bool){
        return supportedInterfaces[_interfaceId];
    }
    
}