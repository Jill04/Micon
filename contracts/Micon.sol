pragma solidity ^0.6.0;

import "./ERC1155Data.sol";
import "./ERC1155Receiver.sol";
import "./Ownable.sol";

abstract contract MiconStorage{
    uint256 constant MAX_EDITION = 10;
    
    uint256 internal miconId = 1;
    
    //Mapping
    mapping(uint256 => uint256[])public miconEditions;
    mapping(uint256 => mapping(uint256 => address))public editionOwner;
    mapping(uint256 => address)public miconCreator;
    mapping(uint256 => mapping(uint256 => address[]))public previouslyOwnedEditionOwners;
    mapping(uint256 => bool)public editionExists;
    mapping(uint256 => address)public miconOwner; // only for micon with no editions
    
    
    //Events
    event MiconCreated(
     address indexed _miconCreator,
     uint256 _miconId,
     uint256 _miconCreationDate
    );
    
    event Edition(
     address indexed _editionOwner,
     address indexed _newEditionOwner,
     uint256 _miconId,
     uint256 _editionId
    );
   
}
    
contract Micon is ERC1155Data,MiconStorage,ERC1155Receiver,Ownable{
    constructor()public ERC1155Data(""){}
   
     /*
     * @dev To create the micon.
     * 
     * @param
     *  '_supply' - specifies number of supply
     */
    function createMicon(uint256 _supply)external onlyOwner(){
         require(_supply != 0 && _supply <= MAX_EDITION,"ERR_EDITION_SHOULD_BE_BETWEEN_1_AND_10");
         miconCreator[miconId] = msg.sender;
        _mintEditions(miconId,_supply);
         emit MiconCreated(address(this),miconId,now);
         miconId++;
    }
    
    //To mint the editions of micon
    function _mintEditions(uint256 _miconId,uint256 _supply)internal{
        if(_supply > 1){
            
               for(uint256 i = 1; i <= _supply; i++){
                miconEditions[_miconId].push(i);
                editionOwner[_miconId][i] = address(this);
                editionExists[_miconId] = true;
            } 
        }
        else{
             miconOwner[miconId] = address(this);
        }
        balances[_miconId][ address(this)] = _supply;
    }
    
    /*
     * @dev To buy the edition of micon.
     * 
     * @param
     *  '_miconId' - specifies the micon id
     *  '_editionNumber' - specifies the edition number of the micon
     */
    function buyEdition(uint256 _miconId, uint256 _editionNumber)external{
        address buyer = msg.sender;
        
        require(_exists(_miconId),"ERR_MICON_DOESNOT_EXISTS");
       
        require(_editionNumber <= miconEditions[_miconId].length,"ERR_EDITION_NUMBER_MISMATCH");
        require(balances[_miconId][buyer] < 1,"ERR_CAN_OWN_ONLY_1_EDITION");
        require(ownerOfEdition(_miconId,_editionNumber) == address(this) || miconOwner[_miconId] == address(this),"ERR_EDITION_ALREADY_SOLD_OR_DOESNOT_EXISTS");
        IERC1155(address(this)).safeTransferFrom(address(this),buyer,_miconId,1,"");
        
        if(editionExists[_miconId]) 
        {
            editionOwner[_miconId][_editionNumber] = buyer;
        }
        else{
            miconOwner[_miconId] = buyer;
            
        }
        emit Edition(address(this),buyer,_miconId,_editionNumber);
    }
    
    //To determine whether micon exists or not
    function _exists(uint256 _miconId) internal view returns (bool) {
       return miconCreator[_miconId] != address(0);
    }
     
     /*
     * @dev To sell the edition of micon.
     * 
     * @param
     *  '_miconId' - specifies the micon id
     *  '_editionNumber' - specifies the edition number of the micon
     */
    function sellEdition(uint256 _miconId, uint256 _editionNumber)external{
        address  seller = msg.sender ;
        
        require(_exists(_miconId),"ERR_MICON_DOESNOT_EXISTS");
        
        if(editionExists[_miconId])
        {
           require(ownerOfEdition(_miconId,_editionNumber) == seller,"ERR_NOT_AN_OWNER_OF_EDITION"); 
           IERC1155(address(this)).safeTransferFrom(seller,address(this),_miconId,1,"");
           editionOwner[_miconId][_editionNumber] = address(this);
        
        }
        else{
             IERC1155(address(this)).safeTransferFrom(seller,address(this),_miconId,1,"");
             miconOwner[_miconId] = address(this);
        }
        previouslyOwnedEditionOwners[_miconId][_editionNumber].push(seller);
        emit Edition(seller,address(this),_miconId,_editionNumber);
    }
    
    // To retrieve the owner of edition of micon.
    function ownerOfEdition(uint256 _miconId , uint256 _editionNumber)internal view returns(address){
       return editionOwner[_miconId][_editionNumber];
    }

}
