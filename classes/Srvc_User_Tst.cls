@isTest
public class Srvc_User_Tst {
    
    private static User adminUser;
    private static User runningUser;
    
    private static void setup(){
        adminUser = CopadoTestDataFactory.createAdminUser();
        insert adminUser;
        
        System.runAs(adminUser){
            runningUser = CopadoTestDataFactory.createStandardUser();
            insert runningUser;
        }
    }
    
    public static void getProfile(){
        setup();
        
        Test.startTest();
        Profile adm = Srvc_User.getProfile('System Administrator');
        Profile std = Srvc_User.getProfile('Standard User');
        
        Test.stopTest();
        
        System.assertNotEquals(null, adm.Id);
        System.assertNotEquals(null, std.Id);
        System.assertNotEquals(adm.Id, std.Id);
    }
    
    public static testmethod void testGetCurrentUser(){
		setup();

        Test.startTest();
        System.debug(adminUSer);
        User usrAdmin = Srvc_User.getUser(adminUser.Id);
        User usrStandard = Srvc_User.getUser(runningUser.Id);
        
        Test.stopTest();
        
        System.assertEquals(adminUser.Id, usrAdmin.Id);
        System.assertEquals(runningUser.Id, usrStandard.Id);
        List<Account> accounts = new List<Account>();
    }
}