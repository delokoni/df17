@isTest
public class TH_Opportunity_Tst {
	
    private static User adminUser;
    private static User runningUser;
    private static Account acct;
    
    private static void setup(){
        adminUser = TestDataFactory.createAdminUser();
        insert adminUser;
        
        System.runAs(adminUser){
            runningUser = TestDataFactory.createStandardUser();
            insert runningUser;
        }
    }
    
    public static testmethod void testOpptyCreation(){
        setup();
        System.runAs(runningUser){  
        	Account acct = TestDataFactory.createAccount('TestAccount');
            insert acct;
            
            Test.startTest();
            Opportunity oppty = TestDataFactory.createOppty(acct, acct.Name);
            insert oppty;
              
            Test.stopTest();
            
            System.assertEquals(acct.Id, oppty.AccountId);
        }   
    }
}