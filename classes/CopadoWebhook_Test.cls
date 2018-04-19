/**
 * Created by kheidt on 19/03/2018.
 */

@IsTest
public class CopadoWebhook_Test {

    private static copado__Org__c credential;
    private static copado__Environment__c env;
    private static copado__Git_Repository__c repo;
    private static copado__Static_Code_Analysis_Settings__c scas;
    private static List<copado__Static_Code_Analysis_Rule__c> scars;
    private static copado__Deployment_Flow__c flow;
    private static copado__Project__c project;
    private static copado__User_Story__c userStory;
    private static Attachment att;

    private static void setUp(){
        env = CopadoTestDataFactory.createEnvironment();
        insert env;

        credential = CopadoTestDataFactory.createOrgCredential(env);
        insert credential;

        repo = CopadoTestDataFactory.createGitRepo();
        insert repo;

        scas = CopadoTestDataFactory.createStaticCodeAnalysisSettings();
        insert scas;

        scars = new List<copado__Static_Code_Analysis_Rule__c>();
        scars.add(CopadoTestDataFactory.createStaticCodeAnalysisRule(scas));
        insert  scars;

        flow = CopadoTestDataFactory.createDeploymentFlow(scas,repo);
        insert flow;

        project = CopadoTestDataFactory.createProject(flow);
        insert project;

        userStory = CopadoTestDataFactory.createUserStory(project, env, credential);
        insert userStory;

        att = CopadoTestDataFactory.createAttachment(userStory.Id);
        insert att;

        CopadoKeys__c cap = CopadoTestDataFactory.createApiKeyCustomSetting();
        insert cap;

    }

    public static testMethod void testCopadoWebhookService() {
        setUp();
        CopadoWebhookCalloutMock calloutMock = new CopadoWebhookCalloutMock();
        calloutMock.mockStaticCodeAnalysisCall();

        Test.setMock(HttpCalloutMock.class, calloutMock);

        System.debug(calloutMock.responseStatus);
        Test.startTest();
        HttpResponse response = CopadoWebhookService.runStaticCodeAnalysisOnUserStory(userStory.Id);
        Test.stopTest();

        System.assertEquals(2, CopadoAttachmentService.items.size());
        System.assertEquals('2018', response.getStatus());
    }
}