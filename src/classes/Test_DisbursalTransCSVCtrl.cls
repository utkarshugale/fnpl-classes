@isTest(SeeAllData = true)
public class Test_DisbursalTransCSVCtrl {
	
    @isTest
    public static void Test_DisbursalTransCSVCtrlMethod(){
        DisbursalTransCSVCtrl dtCtrlObj = new DisbursalTransCSVCtrl();
        dtCtrlObj.createCSV();
    }
}