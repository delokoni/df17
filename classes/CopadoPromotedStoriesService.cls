/**
 * Created by kheidt on 26/11/2018.
 */

public with sharing class CopadoPromotedStoriesService {

    public List<copado__Promoted_User_Story__c> getLastDayPromotedUserStories(Datetime myTime){
        List<copado__Promoted_User_Story__c> lastStories = new List<copado__Promoted_User_Story__c>();

        Datetime startLastDay = myTime.addDays(-1);

        lastStories = [
                SELECT
                        Id,
                        Name,
                        copado__User_Story__c,
                        copado__Promotion__c,
                        copado__Promotion__r.copado__Status__c,
                        copado__Promotion__r.copado__Destination_Environment__c,
                        copado__Promotion__r.copado__Destination_Environment__r.Name,
                        copado__Promotion__r.copado__Destination_Org_Credential__c,
                        copado__Promotion__r.copado__Destination_Org_Credential__r.Name,
                        copado__Promotion__r.copado__Source_Environment__c,
                        copado__Promotion__r.copado__Source_Environment__r.Name,
                        copado__Promotion__r.copado__Source_Org_Credential__c,
                        copado__Promotion__r.copado__Source_Org_Credential__r.Name,
                        copado__Promotion__r.CreatedDate,
                        copado__Promotion__r.LastModifiedDate
                FROM
                        copado__Promoted_User_Story__c
                WHERE
                        LastModifiedDate < :myTime
                        AND
                        LastModifiedDate >= :startLastDay
        ];

        return lastStories;
    }

}