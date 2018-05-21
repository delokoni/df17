/**
 * Created by kheidt on 19/03/2018.
 */

@IsTest
public class CopadoTestDataFactory {

    public static copado__Environment__c createEnvironment(){
        copado__Environment__c env = new copado__Environment__c();
        env.Name = 'UnitTest';
        env.copado__Org_ID__c = UserInfo.getOrganizationId();
        env.copado__Type__c = 'Sandbox';
        env.copado__Minimum_Apex_Test_Coverage__c = 75.00;

        return env;
    }

    public static copado__Org__c createOrgCredential(copado__Environment__c env){
        copado__Org__c org = new copado__Org__c();
        org.Name = env.Name;
        org.copado__Environment__c = env.Id;
        org.copado__Org_Type__c = env.copado__Type__c;
        org.copado__Default_Credential__c = true;
        org.copado__Validated_Date__c = DateTime.now();
        return org;
    }

    public static copado__Git_Repository__c createGitRepo(){
        copado__Git_Repository__c repo = new copado__Git_Repository__c();
        repo.Name = 'UnitTestRepo';
        repo.copado__Git_Provider__c = 'Github';
        repo.copado__URI__c = 'git@github.com:testUser/testRepo.git';
        return repo;
    }

    public static copado__Static_Code_Analysis_Settings__c createStaticCodeAnalysisSettings(){
        copado__Static_Code_Analysis_Settings__c scas = new copado__Static_Code_Analysis_Settings__c();
        scas.Name = 'TestSCAS';
        return scas;
    }

    public static copado__Static_Code_Analysis_Rule__c createStaticCodeAnalysisRule(copado__Static_Code_Analysis_Settings__c scas){
        copado__Static_Code_Analysis_Rule__c scar = new copado__Static_Code_Analysis_Rule__c();
        scar.copado__Static_Code_Analysis_Settings__c = scas.Id;
        scar.copado__Rule_Name__c = 'AvoidSoqlInLoops';
        scar.copado__Message__c = 'Never put SOQL in loops. maybe sometimes. if you are sure.';
        scar.copado__Priority__c = '1';
        return scar;
    }

    public static copado__Deployment_Flow__c createDeploymentFlow(
            copado__Static_Code_Analysis_Settings__c scas,
            copado__Git_Repository__c repo
    ){
        copado__Deployment_Flow__c flow = new copado__Deployment_Flow__c();
        flow.Name = 'UnitTestFlow';
        flow.copado__Main_Branch__c = 'utMaster';
        flow.copado__Git_Repository__c = repo.Id;
        flow.copado__Static_Code_Analysis_Settings__c = scas.Id;
        flow.copado__Active__c = true;
        return flow;
    }

    public static copado__Project__c createProject(copado__Deployment_Flow__c flow){
        copado__Project__c project = new copado__Project__c();
        project.Name ='Unit Test Implementation';
        project.copado__Start_Date__c = Date.today().addDays(-1);
        project.copado__End_Date__c = Date.today().addYears(1);
        project.copado__Index_Metadata__c = true;
        project.copado__Status__c = 'In Progress';
        project.copado__Deployment_Flow__c = flow.Id;
        return project;
    }

    public static copado__User_Story__c createUserStory (
            copado__Project__c project,
            copado__Environment__c env,
            copado__Org__c org
    ){
        copado__User_Story__c us = new copado__User_Story__c();
        us.copado__User_Story_Title__c = 'Unit Test US';
        us.copado__Promotion_Test_Level__c = 'NoTestRun';
        us.copado__Org_Credential__c = org.Id;
        us.copado__Environment__c = env.Id;
        us.copado__Project__c = project.Id;
        return us;
    }

    public static Attachment createAttachment(String parentId){
        Attachment att = new Attachment();
        att.Name = 'Git MetaData';
        String bodyString =
                '[{"t":"ApexTrigger","n":"TestTrigger","cmm":"updated"},' +
                        '{"t":"ApexClass","n":"TestField","cmm":"updated"},' +
                        '{"t":"CustomField","n":"TestObject__c.TestField__c","cmm":"updated"},' +
                        '{"t":"CustomObject","n":"TestObject__c","cmm":"updated"}]';
        Blob bodyBlob = Blob.valueOf(bodyString);
        att.Body = bodyBlob;
        att.ParentId = parentId;
        return att;
    }

    public static CopadoKeys__c createApiKeyCustomSetting(){
        CopadoKeys__c cap = new CopadoKeys__c();
        cap.Name = 'CopadoApiKey';
        cap.Value__c = '1234567890';
        return cap;
    }

    public static CopadoKeys__c createProjectIdCustomSetting(Id projectId){
        CopadoKeys__c cpk = new CopadoKeys__c();
        cpk.Name = 'ProjectId';
        cpk.Value__c = projectId;
        return cpk;
    }

    public static copado__Deployment_Flow_Step__c createDeploymentFlowStep(Id flow, Id source, Id target){
        copado__Deployment_Flow_Step__c dfs = new copado__Deployment_Flow_Step__c();
        dfs.copado__Source_Environment__c = source;
        dfs.copado__Destination_Environment__c = target;
        dfs.copado__Branch__c = 'unitTest';
        dfs.copado__Deployment_Flow__c = flow;

        return dfs;
    }

}