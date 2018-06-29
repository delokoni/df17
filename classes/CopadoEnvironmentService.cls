public class CopadoEnvironmentService {
	
    //get an environment Id based on the name
    public static copado__Environment__c getEnvironementByName(String envName){
        copado__Environment__c env = [
                SELECT
                        Id,
                        Name
                FROM copado__Environment__c
                WHERE Name = :envName
                LIMIT 1
        ];
        return env;
    }
}