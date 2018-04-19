/**
 * Created by kheidt on 18/04/2018.
 */

@IsTest
private class CopadoPromotionServiceTest {

    private static copado__Org__c sourceOrgCredential;
    private static copado__Org__c targetOrgCredential;
    private static copado__Environment__c sourceEnv;
    private static copado__Environment__c targetEnv;
    private static copado__Git_Repository__c repo;
    private static copado__Static_Code_Analysis_Settings__c scas;
    private static List<copado__Static_Code_Analysis_Rule__c> scars;
    private static copado__Deployment_Flow__c flow;
    private static copado__Project__c project;
    private static copado__User_Story__c userStory;
    private static Attachment att;

    private static void setUp(){
        sourceEnv = CopadoTestDataFactory.createEnvironment();
        insert sourceEnv;

        targetEnv = CopadoTestDataFactory.createEnvironment();
        targetEnv.Name = 'ProdUnitTest';
        targetEnv.copado__Org_ID__c = targetEnv.copado__Org_ID__c.left(17) + 'Z';
        insert targetEnv;

        sourceOrgCredential = CopadoTestDataFactory.createOrgCredential(sourceEnv);
        insert sourceOrgCredential;

        targetOrgCredential = CopadoTestDataFactory.createOrgCredential(targetEnv);
        insert targetOrgCredential;

        repo = CopadoTestDataFactory.createGitRepo();
        insert repo;

        scas = CopadoTestDataFactory.createStaticCodeAnalysisSettings();
        insert scas;

        scars = new List<copado__Static_Code_Analysis_Rule__c>();
        scars.add(CopadoTestDataFactory.createStaticCodeAnalysisRule(scas));
        insert  scars;

        flow = CopadoTestDataFactory.createDeploymentFlow(scas,repo);
        insert flow;

        copado__Deployment_Flow_Step__c dfs = CopadoTestDataFactory.createDeploymentFlowStep(flow.Id,sourceEnv.Id, targetEnv.Id);
        insert dfs;
        
        project = CopadoTestDataFactory.createProject(flow);
        insert project;

        userStory = CopadoTestDataFactory.createUserStory(project, sourceEnv, sourceOrgCredential);
        userStory.copado__Promote_Change__c = true;
        insert userStory;

        att = CopadoTestDataFactory.createAttachment(userStory.Id);
        insert att;

        CopadoKeys__c cap = CopadoTestDataFactory.createApiKeyCustomSetting();
        insert cap;

        CopadoKeys__c cpk = CopadoTestDataFactory.createProjectIdCustomSetting(String.valueOf(project.Id) );
        insert cpk;

    }

    static testMethod void testBehavior() {
        setUp();

        Test.startTest();
        CopadoPromotionService.createAndDeployPromotionForProject(new List<Id>{sourceEnv.Id});
        Test.stopTest();
    }
}