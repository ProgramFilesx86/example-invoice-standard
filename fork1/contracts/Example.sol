// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

interface IERC20 {
  function transferFrom(address,address,uint256) external;
}
contract example {
  // events

   event paid(uint256,address);
   event created(uint256,address);
   event canceled(uint256);

   address public owner;
   uint256 id;
   struct invoice {
     address creator;
     address payer;
     address payto;
     uint256 amount;
     IERC20 token;
     uint256 _id;
   }
   mapping(IERC20=>bool) public whitelisted;

   constructor()  {
     owner = msg.sender;
   }
   //only owner 
   function whitelist(IERC20 token) external {
      require(msg.sender == owner,"auth");
      whitelisted[token] = true;
   }

   function transferOwnership(address _new) external {
     require(msg.sender == owner,"auth");
     owner = _new;
   }


   invoice[] public invoices; 
   // create an invoice
   // @param _payer the address who will pay the invoice
   // @param _to the address who the invoice will be paid to
   // @param _amount the amount of the invoice
   // @param _token the token address of what the invoices will be paid 
   function create(address _payer, address to, uint256 amount, IERC20 _token) external {
       invoice memory _inv;
       require(whitelisted[_token],"unknown token");
       _inv = invoice(msg.sender,_payer,to,amount,_token, id++);
       invoices.push(_inv);
       emit created(_inv._id,msg.sender);
   }
   // pay a specific invoice
   // @param _iid the invoice id to pay
   
   function pay(uint256 iid) external {
         invoice memory _inv = invoices[iid];
         require(_inv.payer == msg.sender,"user pay on behalf");
         IERC20(_inv.token).transferFrom(_inv.payer,_inv.payto,_inv.amount);
         emit paid(iid,msg.sender);
         delete invoices[iid];
   }
   // pay a specific invoice
   // @param _iid the invoice id to pay
   // you must be the creator of the invoice to cancel it
   function cancel(uint256 iid) external {
         invoice memory _inv = invoices[iid];
         require(_inv.creator == msg.sender,"you can only cancel yours");
         delete invoices[iid];
         emit canceled(iid);
   } 
}
