/**
 * Due to the way salesforce works the test-class needs to run with ability to access actual salesforce data
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
            sourceEnv = CopadoTestDataFactory.createEnvironment();
            sourceEnv.copado__Org_ID__c = sourceEnv.copado__Org_ID__c.left(17) + 'Z';
            insert sourceEnv;
            
            targetEnv = CopadoTestDataFactory.createEnvironment();
            targetEnv.Name = 'ProdUnitTest';
            targetEnv.copado__Org_ID__c = targetEnv.copado__Org_ID__c.left(17) + 'Y';
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
            flow.copado__Active__c = false;
            insert flow;
            
            
            flow.copado__Active__c = true;
            system.debug(flow);
            update flow;
            
            copado__Deployment_Flow_Step__c dfs = CopadoTestDataFactory.createDeploymentFlowStep(flow.Id,sourceEnv.Id, targetEnv.Id);
            insert dfs;
            
            project = CopadoTestDataFactory.createProject(flow);
            insert project;
            
            userStory = CopadoTestDataFactory.createUserStory(project, sourceEnv, sourceOrgCredential);
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

    static testMethod void testCreateAndDeployPromotion() {
        setUp();

        CopadoWebhookCalloutMock calloutMock = new CopadoWebhookCalloutMock();
        calloutMock.mockCreatePromotionAndDeployCall();
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        
        System.debug(calloutMock.responseStatus);
        System.runAs(runningUser){
            Test.startTest();
            CopadoPromotionService.createAndDeployForwardPromotion(sourceEnv.Name,project.Name);
            Test.stopTest();
            
            System.debug(CopadoPromotionService.callResponse);
            
            System.assertEquals('2019', CopadoPromotionService.callResponse.getStatus() );
        }
    }

    static testMethod void testSchedulePromotion(){
        setUp();
        CopadoWebhookCalloutMock calloutMock = new CopadoWebhookCalloutMock();
        calloutMock.mockCreatePromotionAndDeployCall();

        Test.setMock(HttpCalloutMock.class, calloutMock);

        System.debug(calloutMock.responseStatus);
            System.runAs(runningUser){
            Test.startTest();
            // This test runs a scheduled job at midnight Sept. 3rd. 2022
            String CRON_EXP = '0 0 0 3 9 ? 2022';
    
            // Schedule the test job
            CopadoSchedulePromotion csp = new CopadoSchedulePromotion(sourceEnv.Name, project.Name);
            csp.environmentName = sourceEnv.Name;
            csp.projectName = project.Name;
            String jobId = System.schedule('BorrarAseguradosTest', CRON_EXP, csp);
    
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    
            // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
    
            // Verify the next time the job will run
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
            Test.stopTest();
            }
    }
}