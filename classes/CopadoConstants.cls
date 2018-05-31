/**
 * Created by kheidt on 19/03/2018.
 */

public with sharing class CopadoConstants {

    public static final String webhookBase = 'https://copado.herokuapp.com';
    public static final String analyseStaticCodeBase = '/json/v1/webhook/analyseStaticCode/';
    public static final String deployPromotionBase= '/json/v1/webhook/promotions/';

    //apiKeys are security relevant, so if you store them outside of the page, please make sure only certain users can access it.
    //custom setting only for
    public Static final String apiKey = CopadoKeys__c.getInstance('CopadoApiKey').Value__c;

    //test level strings
    // https://resources.docs.salesforce.com/sfdc/pdf/salesforce_migration_guide.pdf
    public static final String runAllTests = 'RunAllTestsInOrg';
    public static final String runSelectedTests = 'RunSpecifiedTests';
    public static final String runLocalTests = 'RunLocalTests';
    public static final String noTestRun = 'NoTestRun';

    public static final String projectId = CopadoKeys__c.getInstance('ProjectId').Value__c;
}