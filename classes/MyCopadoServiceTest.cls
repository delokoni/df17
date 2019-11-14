@isTest
Public Class MyCopadoServiceTest{


    public static testmethod void testMyCopadoTestMethod(){
    
        MyCopadoService mcs = new MyCopadoService();
        
        Test.startTest();
        mcs.myCopadoServiceMethod();
        Test.stopTest();
        
        System.assertEquals(1,1);
    
    }

}