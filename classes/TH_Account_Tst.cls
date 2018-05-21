@isTest
public class TH_Account_Tst {
	
    private static User adminUser;
    private static User runningUser;
    
    private static void setup(){
        adminUser = TestDataFactory.createAdminUser();
        insert adminUser;
        
        System.runAs(adminUser){
            runningUser = TestDataFactory.createStandardUser();
            insert runningUser;
        }
    }
    
    public static testmethod void testAccountCreation(){
        setup();
        System.runAs(runningUser){    
            
            Test.startTest();
            Account acct = TestDataFactory.createAccount('Test Client, Inc.');
            insert acct;
            Test.stopTest();
            
            System.assertEquals('Test Client, Inc.', acct.Name);
        }
    }
}