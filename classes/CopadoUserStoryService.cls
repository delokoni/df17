/**
 * Created by kheidt on 17/04/2018.
 */

public with sharing class CopadoUserStoryService {

    public static Map<Id, copado__User_Story__c> getUserStoriesToBePromoted(String projectId, String envId){
        Map<Id,copado__User_Story__c> stories = new Map<Id, copado__User_Story__c>([
                SELECT
                        Id,
                        Name,
                        copado__Environment__c,
                        copado__Org_Credential__c
                FROM copado__User_Story__c
                WHERE
                        copado__Project__c = :projectId AND
                        copado__Environment__c = :envId AND
                        copado__Promote_Change__c = TRUE
        ]);

        return stories;
    }

    public static copado__User_Story__c getUserStory(String usId){
        copado__User_Story__c us = [
                SELECT
                        Id,
                        Name,
                        copado__Org_Credential__c,
                        copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__c,
                        copado__Project__r.copado__Deployment_Flow__r.copado__Static_Code_Analysis_Settings__c
                FROM copado__User_Story__c
                WHERE Id = :usId
                LIMIT 1
        ];
        return us;
    }
}