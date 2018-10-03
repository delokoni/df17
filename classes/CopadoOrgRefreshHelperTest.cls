@isTest
public class CopadoOrgRefreshHelperTest {
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
    private static copado__Git_Backup__c snapshotOne;
    private static copado__Git_Backup__c snapshotTwo;
    private static String oldOrgId;
    private static string newOrgId;
    private static string oldBranchName;
    private static string newBranchName;


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
            dfs.copado__Branch__c = 'source';
            dfs.copado__Destination_Branch__c = 'target'; 
            insert dfs;
            
            snapshotOne = CopadoTestDataFactory.createGitSnapshot(sourceOrgCredential, repo.Id, 'source');
            insert snapshotOne;
            
            snapshotTwo = CopadoTestDataFactory.createGitSnapshot(targetOrgCredential, repo.Id, 'target');
            insert snapshotTwo;

            project = CopadoTestDataFactory.createProject(flow);

            if(CopadoTestDataFactory.hasCopadoIntegration){
                // create setting record
                SObject setting = CopadoTestDataFactory.createIntegrationSetting();
                Type sType = Type.forName('Copado_Integration_Setting__c');
                Database.insertImmediate(setting);

                project = CopadoTestDataFactory.addIntegrationSetting(project, (String) setting.Id);

                insert project;
            } else{
                insert project;
            }
            
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
    
    public static testmethod void testChangeSourceEnv(){
        setUp();
        
        oldOrgId = sourceEnv.copado__Org_ID__c;
        newOrgId = sourceEnv.copado__Org_ID__c.left(17) + 'N';
        oldBranchName = 'source';
        newBranchName = 'source_nw';
        
        Test.startTest();
        
        System.runAs(runningUser){
            CopadoOrgRefreshHelper.changeCopadoElementsAfterOrgRefresh(oldOrgId, newOrgId, oldBranchName, newBranchName);
            
            System.assertEquals(newOrgId, CopadoEnvironmentService.getEnvironementByName(sourceEnv.Name).copado__Org_ID__c);
            System.assertNotEquals(newOrgId, CopadoEnvironmentService.getEnvironementByName(targetEnv.Name).copado__Org_ID__c);
            
            System.assertEquals(newOrgId, CopadoOrgCredentialService.getOrgCredentialsForEnvironment(sourceEnv).values()[0].copado__SFDC_Org_ID__c.left(18));
			System.assertNotEquals(newOrgId, CopadoOrgCredentialService.getOrgCredentialsForEnvironment(targetEnv).values()[0].copado__SFDC_Org_ID__c.left(18));
            
            System.debug(CopadoFlowStepService.getFlowStepsForEnvironment(sourceEnv)[0]);
            System.debug(CopadoFlowStepService.getFlowStepsForEnvironment(targetEnv)[0]);
            
            System.assertEquals(newBranchName, CopadoFlowStepService.getFlowStepsForEnvironment(sourceEnv)[0].copado__Branch__c);
            System.assertNotEquals(newBranchName, CopadoFlowStepService.getFlowStepsForEnvironment(sourceEnv)[0].copado__Destination_Branch__c);
            
            System.assertEquals(newBranchName, CopadoGitSnapshotService.getGitSnapshotsForEnvironment(sourceEnv.Id)[0].copado__Branch__c);
            System.assertNotEquals(newBranchName, CopadoGitSnapshotService.getGitSnapshotsForEnvironment(targetEnv.Id)[0].copado__Branch__c);
        }
        Test.stopTest();
    }
    
    
    
    public static testmethod void testChangeTargetEnv(){
        setUp();
        
        oldOrgId = targetEnv.copado__Org_ID__c;
        newOrgId = targetEnv.copado__Org_ID__c.left(17) + 'N';
        oldBranchName = 'target';
        newBranchName = 'target_nw';
        
        Test.startTest();
        
        System.runAs(runningUser){
            CopadoOrgRefreshHelper.changeCopadoElementsAfterOrgRefresh(oldOrgId, newOrgId, oldBranchName, newBranchName);
            
            System.assertNotEquals(newOrgId, CopadoEnvironmentService.getEnvironementByName(sourceEnv.Name).copado__Org_ID__c);
            System.assertEquals(newOrgId, CopadoEnvironmentService.getEnvironementByName(targetEnv.Name).copado__Org_ID__c);
            
            System.assertNotEquals(newOrgId, CopadoOrgCredentialService.getOrgCredentialsForEnvironment(sourceEnv).values()[0].copado__SFDC_Org_ID__c.left(18));
			System.assertEquals(newOrgId, CopadoOrgCredentialService.getOrgCredentialsForEnvironment(targetEnv).values()[0].copado__SFDC_Org_ID__c.left(18));
            
            System.assertNotEquals(newBranchName, CopadoFlowStepService.getFlowStepsForEnvironment(sourceEnv)[0].copado__Branch__c);
            System.assertEquals(newBranchName, CopadoFlowStepService.getFlowStepsForEnvironment(sourceEnv)[0].copado__Destination_Branch__c);
            
            System.assertNotEquals(newBranchName, CopadoGitSnapshotService.getGitSnapshotsForEnvironment(sourceEnv.Id)[0].copado__Branch__c);
            System.assertEquals(newBranchName, CopadoGitSnapshotService.getGitSnapshotsForEnvironment(targetEnv.Id)[0].copado__Branch__c);
        }
        Test.stopTest();
    }
}