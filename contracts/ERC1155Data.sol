pragma solidity ^0.6.0;

import "./IERC1155.sol";
import "./ERC165.sol";
import "./Math.sol";
import "./IERC1155Receiver.sol";
import "./IERC1155Metadata.sol";

contract ERC1155Data is ERC165,IERC1155,IERC1155Metadata{
    using Math for uint;
    
    string private  _uri;
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;
    
    constructor(string memory uri_) public{
         _setURI(uri_);
        _registerInterface(_INTERFACE_ID_ERC1155);
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }
       
        
        mapping(address => mapping(address => bool)) private operatorApproval;
        mapping(uint256 => mapping(address => uint256))public balances;
        
        function balanceOf(address _account,uint256 _id)external view override returns(uint256){
            require(_account != address(0),"ERC1155: balance query for the zero address");
            return balances[_id][_account];
        }
        
        function balanceOfBatch(address[]memory _accounts,uint256[] memory _ids)external view override returns(uint256[] memory){
            
            require(_accounts.length == _ids.length,"ERC1155: accounts and ids length vary");
            
            uint256[] memory batchBalance = new uint256[](_accounts.length);
            
            for(uint256 i = 0 ;i< _accounts.length; i++){
                 require(_accounts[i] != address(0),"ERC1155: balance query for the zero address");
                 batchBalance[i] =  balances[_ids[i]][_accounts[i]];
                
            }
            return batchBalance;
        }
        
        function setApprovalForAll(address _operator, bool _approved)external override{
            
             require(_operator != msg.sender,"ERC1155: Cannot approve the owner itself");
             
             operatorApproval[msg.sender][_operator] = _approved;
             emit ApprovalForAll(msg.sender, _operator, _approved);
        }
        
        function isApprovedForAll(address _account, address _operator)public view override returns(bool){
            return operatorApproval[_account][_operator];
        }
        
        function safeTransferFrom(address _from, address _to,uint256 _id,uint256 _amount, bytes calldata data)public override{
            require(_to != address(0),"ERC1155: transfer to zero address");
        
            require(_from == msg.sender || isApprovedForAll(_from,msg.sender),"ERC1155: the is sender not the owner nor approved");
            
            balances[_id][_from] = balances[_id][_from].sub(_amount,"ERC1155: insufficient balance for transfer");
            balances[_id][_to] = balances[_id][_to].add(_amount);
            
            emit TransferSingle(msg.sender, _from, _to, _id, _amount);

            _safeTransferCheck(msg.sender, _from, _to, _id, _amount, data);
            
        }
        
         function safeBatchTransferFrom(address _from, address _to,uint256[] memory _ids,uint256[] memory _amounts, bytes calldata data)public override
         {
            require(_to != address(0),"ERC1155: transfer to zero address");
            
            require(_from == msg.sender || isApprovedForAll(_from,msg.sender),"ERC1155: the is sender not the owner nor approved");
            
            for(uint i = 0;i< _ids.length;i++)
            {
                balances[_ids[i]][_from] = balances[_ids[i]][_from].sub(_amounts[i],"ERC1155: insufficient balance for transfer");
                balances[_ids[i]][_to] = balances[_ids[i]][_to].add(_amounts[i]);
             }
            
           emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
           
          _safeBatchTransferCheck(msg.sender, _from, _to, _ids, _amounts, data);
         }
         
         function _safeTransferCheck(address _operator,address _from , address _to,uint256 _id,uint256 _amount, bytes memory _data) internal{
             if(isContract(_to))
             {
                 try IERC1155Receiver(_to).onERC1155Received(_operator,_from,_id,_amount,_data)returns(bytes4 result){
                    if(result != IERC1155Receiver(_to).onERC1155Received.selector){
                        revert("ERC1155: IERC1155Receiver rejected tokens");
                    } 
                 } catch Error(string memory error) {
                    revert(error);
                } catch {
                    revert("ERC1155: transfer to non ERC1155Receiver implementer");
                }
             }
          }
         
         function _safeBatchTransferCheck(address _operator,address _from , address _to,uint256[] memory _ids,uint256[] memory  _amounts, bytes memory _data) internal{
             if(isContract(_to))
             {
                     try IERC1155Receiver(_to).onERC1155BatchReceived(_operator,_from,_ids,_amounts,_data)returns(bytes4 result){
                    if(result != IERC1155Receiver(_to).onERC1155BatchReceived.selector){
                        revert("ERC1155: IERC1155Receiver rejected tokens");
                    } 
                 } catch Error(string memory error) {
                    revert(error);
                } catch {
                    revert("ERC1155: transfer to non ERC1155Receiver implementer");
                }
             }
           }
           
           
          function _setURI(string memory _metauri)internal {
               _uri = _metauri;
               
           }
           
          function uri(uint256) external view override returns (string memory){
                   return _uri;
            }
               
           function isContract(address account) internal view returns (bool) {
                uint256 size;
                assembly { size := extcodesize(account) }
                return size > 0;
            }
    } 