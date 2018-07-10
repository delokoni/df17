/**
 * This class is a helper to automate the refresh process
 **/
public class CopadoOrgRefreshHelper {
    
    public static String oldOrgId;
    public static String newOrgId;
    public static String oldBranchName;
    public static String newBranchName;
    
    public static void changeCopadoElementsAfterOrgRefresh(
    	String oldOrg,
        String newOrg,
        String oldBranch,
        String newBranch
    ){
        oldOrgId = oldOrg;
        newOrgId = newOrg;
        oldBranchName = oldBranch;
        newBranchName = newBranch;
        
        copado__Environment__c env = changeOrgIdOnEnvironment(oldOrgId, newOrgId);
        Map<String, copado__Org__c> orgCreds = changeSFIDOnOrgCredentials(env);
        List<copado__Deployment_Flow_Step__c> steps = changeBranchReferenceOnFlowSteps(env, oldBranchName, newBranchName);
        List<copado__Git_Backup__c> snapshots = changeBranchReferenceOnGitSnapshots(env, oldBranchName, newBranchName);
    }
    
    public static copado__Environment__c changeOrgIdOnEnvironment(String oldEnvId, String newEnvId){        
        
        //get the environment
        copado__Environment__c env = CopadoEnvironmentService.getEnvironmentByOrgId(oldEnvId);
        
        //change thee org Id to the new one and update the record
        env.copado__Org_ID__c = newEnvId;
        update env;
        
        return env;
    }
    
    public static Map<String, copado__Org__c> changeSFIDOnOrgCredentials(copado__Environment__c env){
        
        //get a list of org credentials
        Map<String, copado__Org__c> orgCreds = CopadoOrgCredentialService.getOrgCredentialsForEnvironment(env);
        
        //on each org credentials, the reference to the environment needs to be updated
        for(copado__Org__c oc : orgCreds.values()){
            
            //split the key orgId_userId
            List<String> splittedKey = oc.copado__SFDC_Org_ID__c.split('_');
            String keyPart1 = splittedKey[0];
            String keyPart2 = splittedKey[1];
            
            //update the environment Id part of the key
            oc.copado__SFDC_Org_ID__c = env.copado__Org_ID__c + '_' + keyPart2;
        }
        
        update orgCreds.values();
        
        return orgCreds;
    }
    
    public static List<copado__Deployment_Flow_Step__c> changeBranchReferenceOnFlowSteps(copado__Environment__c env, String oldBranch, String newBranch){
        
        //get a list of flow steps linked to an environment
        List<copado__Deployment_Flow_Step__c> steps = CopadoFlowStepService.getFlowStepsForEnvironment(env);
        
        //depending on if the environment is destination or source, set the branch reference correctly
        for(copado__Deployment_Flow_Step__c s : steps){
            if(env.Id == s.copado__Source_Environment__c){
                System.debug('changing source branch');
                s.copado__Branch__c = newBranch;
            } else if(env.Id == s.copado__Destination_Environment__c){
                System.debug('changing destination branch');
                s.copado__Destination_Branch__c = newBranch;
            } else {
                System.debug('no change on flow step');
            }
        }
        update steps;
        
        return steps;
    }
    
    public static List<copado__Git_Backup__c> changeBranchReferenceOnGitSnapshots(copado__Environment__c env, String oldBranch, String newBranch){
        
        //get a list of git snapshots linked to the same environment
        List<copado__Git_Backup__c> snapshots = CopadoGitSnapshotService.getGitSnapshotsForEnvironment(env.Id);
        for(copado__Git_Backup__c s: snapshots){
            if(s.copado__Branch__c == oldBranch){
                s.copado__Branch__c = newBranch;
            }
        }
        
        update snapshots;
        return snapshots;
    }
    
}