@isTest
public class Utility_Tst {
    public static testmethod void testDefaultCompanyCurrency(){
        
        String thisCurrency = Utility.companyCurrency;
        Utility.debugSomeComments();
        
        System.assertEquals('EUR', thisCurrency);
    }

}