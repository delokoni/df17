public class CopadoOrgCredentialService {

    public static Map<String, copado__Org__c> getOrgCredentialsForEnvironment(copado__Environment__c env){
        
        Map<String, copado__Org__c> orgCredMap = new Map<String, copado__Org__c>(
            [
                SELECT Id, Name, copado__SFDC_Org_ID__c 
                FROM copado__Org__c 
                WHERE copado__Environment__c = :env.Id
            ]
        );
        return orgCredMap;
    }
    
}