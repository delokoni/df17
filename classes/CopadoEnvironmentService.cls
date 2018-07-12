public class CopadoEnvironmentService {
	
    //get an environment Id based on the name
    public static copado__Environment__c getEnvironementByName(String envName){
        copado__Environment__c env = [
                SELECT
                        Id,
                        Name,
            			copado__Org_ID__c
                FROM copado__Environment__c
                WHERE Name = :envName
                LIMIT 1
        ];
        return env;
    }
    
    //get an environment based on the external Id; 18 digits
    public static copado__Environment__c getEnvironmentByOrgId(String orgId){
        copado__Environment__c env = [
                SELECT
                        Id,
                        Name,
            			copado__Org_ID__c 
                FROM copado__Environment__c
                WHERE copado__Org_ID__c = :orgId
                LIMIT 1
        ];
        return env;
    }
}