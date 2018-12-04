/**
 * Created by kheidt on 03/12/2018.
 */

@IsTest
private class CopadoDeleteMeTest {
    static testMethod void testDeleteMe() {
        Test.startTest();
        System.assertEquals('Hello World, pls delete me', CopadoDeleteMe.deleteMe());
        Test.stopTest();
    }
}