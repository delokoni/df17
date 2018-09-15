/**
 * Created by kheidt on 14/09/2018.
 */

@IsTest
private class Service_RecentItemsTest {

    static User adminUser;
    static User runningUser;

    static void setUp(){
        //create admin user for creating running user
        adminUser = CopadoTestDataFactory.createAdminUser();
        insert adminUser;

        System.runAs(adminUser){
            //create running user
            runningUser = CopadoTestDataFactory.createStandardUser();
            insert runningUser;
        }

        System.runAs(runningUser){
            Account newAccount = new Account();
            newAccount.Name = 'Test Account';
            insert newAccount;
        }
    }

    static testMethod void testGetRecentlyViewed() {

        setUp();

        Test.startTest();
        System.runAs(runningUser){
            for(RecentlyViewed rv : Service_RecentItems.getRecentlyViews()){
                System.debug(rv);
            }
        }
        Test.stopTest();
    }
}