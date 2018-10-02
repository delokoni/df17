/**
 * Created by kheidt on 01/10/2018.
 */

@IsTest
private class CopadoDeploymentTHTest {

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
    private static copado__Deployment__c dpl1;
    private static copado__Deployment__c dpl2;


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

    static testMethod void testPauseDeploymentStepCreation() {

        setUp();

        List<copado__Deployment__c> deployments = new List<copado__Deployment__c>();

        System.runAs(runningUser){
            dpl1 = CopadoTestDataFactory.createDeployment(sourceOrgCredential.Id);
            dpl2 = CopadoTestDataFactory.createDeployment(sourceOrgCredential.Id);
            dpl2.Name += CopadoConstants.pauseDeploymentString;

            System.debug('this deployment should trigger the step creation' + dpl2);

            deployments.add(dpl1);
            deployments.add(dpl2);

            Test.startTest();

            //testTrigger
            insert deployments;
            Test.stopTest();
        }

        //get created steps
        List<copado__Step__c> steps = new List<copado__Step__c>([
                SELECT Id, Name, copado__Type__c, copado__Status__c, copado__Order__c
                FROM copado__Step__c
                WHERE
                        copado__Deployment__c = :dpl1.Id OR
                        copado__Deployment__c = :dpl2.Id
        ]);

        System.assertEquals(1, steps.size());
        System.assertEquals('Manual Task', steps[0].copado__Type__c);
    }
}