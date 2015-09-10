trigger TotalAmountRollup  on loan__Repayment_Schedule__c (after insert,after update,after delete,before update) 
{


 
 TotalAMountEventHandler.SomeMethod(Trigger.new,Trigger.old, Trigger.isInsert, Trigger.IsUpdate, Trigger.IsDelete) ;
    TotalAMountEventHandler v=new TotalAMountEventHandler();
 //v.BeforeUpdate(Trigger.new);
}