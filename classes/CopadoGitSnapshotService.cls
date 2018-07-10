public class CopadoGitSnapshotService {

    //get git snapshots linked to a specific environment
    public static List<copado__Git_Backup__c> getGitSnapshotsForEnvironment(String envId){
        List<copado__Git_Backup__c> gs = new List<copado__Git_Backup__c>(
        	[
                SELECT Id, Name, copado__Branch__c, copado__Org__r.copado__Environment__c
                FROM copado__Git_Backup__c
                WHERE copado__Org__r.copado__Environment__c = :envId
        	]
        );
        return gs;
    }
    
}