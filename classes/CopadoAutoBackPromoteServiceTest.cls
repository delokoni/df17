/**
 * Created by kheidt on 28/09/2018.
 */

@IsTest
private class CopadoAutoBackPromoteServiceTest {


    private static copado__Org__c sourceOrgCredential;
    private static copado__Org__c targetOrgCredential;
    private static copado__Environment__c sourceEnv1;
    private static copado__Environment__c sourceEnv2;
    private static copado__Environment__c sourceEnv3;
    private static copado__Environment__c targetEnv;
    private static copado__Git_Repository__c repo;
    private static copado__Static_Code_Analysis_Settings__c scas;
    private static List<copado__Static_Code_Analysis_Rule__c> scars;
    private static copado__Deployment_Flow__c flow;
    private static copado__Project__c project;
    private static CopadoKeys__c oldProjectId;
    private static copado__User_Story__c userStory;
    private static Attachment att;
    private static User runningUser;
    private static User adminUser;
    private static Id copadoPermissionSet;
    private static copado.GlobalAPI.UserLicense restoreUser;
    private static CopadoLicenseUtility clu;


    private static void setUp(){
        //create admin user for creating running user
        adminUser = CopadoTestDataFactory.createAdminUser();
        insert adminUser;

        System.runAs(adminUser){
            //create running user
            runningUser = CopadoTestDataFactory.createStandardUser();
            insert runningUser;

            //get copado permission set
            copadoPermissionSet = CopadoTestDataFactory.getCopadoUserPermissionSet().Id;

            //assign permission set to user
            PermissionSetAssignment psa = new PermissionSetAssignment
                    (
                            PermissionSetId = copadoPermissionSet,
                            AssigneeId = runningUser.Id
                    );
            insert psa;

            //assign copado licenses to running User
            clu = new CopadoLicenseUtility();

            //store the Id of the old user, as we need it to restore licenses later, if required.
            //it can be null. if null, an existing non used license was used.
            restoreUser = clu.assignLicenseForTestRun(runningUser.Id);
        }

        System.runAs(runningUser){
            sourceEnv1 = CopadoTestDataFactory.createEnvironment();
            sourceEnv1.copado__Org_ID__c = sourceEnv1.copado__Org_ID__c.left(17) + 'W';
            insert sourceEnv1;

            sourceEnv2 = CopadoTestDataFactory.createEnvironment();
            sourceEnv2.copado__Org_ID__c = sourceEnv2.copado__Org_ID__c.left(17) + 'X';
            insert sourceEnv2;

            sourceEnv3 = CopadoTestDataFactory.createEnvironment();
            sourceEnv3.copado__Org_ID__c = sourceEnv3.copado__Org_ID__c.left(17) + 'Y';
            insert sourceEnv3;

            targetEnv = CopadoTestDataFactory.createEnvironment();
            targetEnv.Name = 'ProdUnitTest';
            targetEnv.copado__Org_ID__c = targetEnv.copado__Org_ID__c.left(17) + 'Z';
            insert targetEnv;

            sourceOrgCredential = CopadoTestDataFactory.createOrgCredential(sourceEnv1);
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
            flow.copado__Active__c = false;
            insert flow;


            flow.copado__Active__c = true;
            system.debug(flow);
            update flow;

            copado__Deployment_Flow_Step__c dfs1 = CopadoTestDataFactory.createDeploymentFlowStep(flow.Id,sourceEnv1.Id, targetEnv.Id);
            dfs1.copado__Branch__c = 'dev1';
            dfs1.copado__Destination_Branch__c = 'uat';
            dfs1.copado__Destination_Environment__c = targetEnv.Id;
            insert dfs1;

            copado__Deployment_Flow_Step__c dfs2 = CopadoTestDataFactory.createDeploymentFlowStep(flow.Id,sourceEnv2.Id, targetEnv.Id);
            dfs2.copado__Branch__c = 'dev2';
            dfs1.copado__Destination_Branch__c = 'uat';
            dfs1.copado__Destination_Environment__c = targetEnv.Id;
            insert dfs2;

            copado__Deployment_Flow_Step__c dfs3 = CopadoTestDataFactory.createDeploymentFlowStep(flow.Id,sourceEnv3.Id, targetEnv.Id);
            dfs3.copado__Branch__c = 'dev3';
            dfs1.copado__Destination_Branch__c = 'uat';
            dfs1.copado__Destination_Environment__c = targetEnv.Id;
            insert dfs3;

            project = CopadoTestDataFactory.createProject(flow);
            insert project;

            userStory = CopadoTestDataFactory.createUserStory(project, sourceEnv1, sourceOrgCredential);
            userStory.copado__Promote_Change__c = true;
            insert userStory;

            att = CopadoTestDataFactory.createAttachment(userStory.Id);
            insert att;

            if(CopadoKeys__c.getInstance('CopadoApiKey') == null) {
                CopadoKeys__c cap = CopadoTestDataFactory.createApiKeyCustomSetting();
                insert cap;
            }

            if(CopadoKeys__c.getInstance('ProjectId') == null) {
                CopadoKeys__c cpk = CopadoTestDataFactory.createProjectIdCustomSetting(String.valueOf(project.Id));
                insert cpk;
            } else{
                oldProjectId = CopadoKeys__c.getInstance('ProjectId');
                oldProjectId.Value__c = project.Id;
                update oldProjectId;
            }
        }
    }

    static testMethod void testAutoBackPromotions() {
        setup();

        CopadoWebhookCalloutMock calloutMock = new CopadoWebhookCalloutMock();
        calloutMock.mockCreatePromotionAndDeployCall();

        Test.setMock(HttpCalloutMock.class, calloutMock);

        System.debug(calloutMock.responseStatus);

        Test.startTest();
        System.runAs(runningUser) {
            //create promotion to have a valid Id to pass for the mass auto back promotion creation
            copado__Promotion__c forwardPromotion = CopadoPromotionService.createForwardPromotion(sourceEnv1.Id, project.Id);
            insert forwardPromotion;

            //Attach stories to promotion:
            List<copado__Promoted_User_Story__c> promotedUserStories = CopadoPromotionService.attachUserStoriesBasedOnProject(forwardPromotion.Id);
            insert promotedUserStories;

            CopadoAutoBackPromoteService cab = new CopadoAutoBackPromoteService(forwardPromotion);
            cab.createBackPromotionsForLowerOrgs();
            Test.stopTest();
        }
    }
}