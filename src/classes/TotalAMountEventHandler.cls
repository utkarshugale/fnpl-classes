public class TotalAMountEventHandler
{
    public static void SomeMethod(List<loan__Repayment_Schedule__c> newOpp,List<loan__Repayment_Schedule__c> oldOpp,Boolean IsInsert,Boolean IsUpdate,Boolean IsDelete)
    {
        set<id> oppAccId=new set<id>();
        if(IsInsert)
        {
            for(loan__Repayment_Schedule__c op:newOpp)
            {
                oppAccId.add(op.Id);
            }
        }
        if(IsUpdate||IsDelete)
        {
            for(loan__Repayment_Schedule__c o:oldOpp)
            {
                oppAccId.add(o.loan__Loan_Account__c);
            }
        }
        Map<Id,loan__Loan_Account__c> amap=new Map<Id,loan__Loan_Account__c>([select id,name from loan__Loan_Account__c where id in:oppAccId]);
        List<loan__Loan_Account__c> toUpdate=new List<loan__Loan_Account__c>();
        for(loan__Loan_Account__c a:[select id,name,(select id,loan__Loan_Account__c,loan__Paid_Total__c from loan__Repayment_Schedule__r),Total_payments__c from loan__Loan_Account__c where id in:oppAccId])
        {
            decimal count=0;
            if(amap.containsKey(a.id))
            {
                
                for(integer i=0;i<a.loan__Repayment_Schedule__r.size();i++)
                {
                    count=count+a.loan__Repayment_Schedule__r[i].loan__Paid_Total__c ;
                }
            }
            amap.get(a.id).Total_payments__c=count;
            toUpdate.add(amap.get(a.id));
            
        }
        update toUpdate;
    }
  /*public  void BeforeUpdate(List<loan__Repayment_Schedule__c> newOpp)
   {
       for(loan__Repayment_Schedule__co:newOpp)
       {
           if(o.Description==null)
           {
               o.Description='From Trigger In Event Handler';
           }
       }
   }*/

}