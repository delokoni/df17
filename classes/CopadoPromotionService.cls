/**
 * Created by kheidt on 17/04/2018.
 */

public with sharing class CopadoPromotionService {

    public static copado__Promotion__c queriedPromotion = new copado__Promotion__c();
    public static HttpResponse callResponse;

    //invocable method to be called from process builder. Project ID must be hardcoded, e.g. in a custom setting
    @InvocableMethod
    public static void createAndDeployPromotionForProject(
            List<Id> envs
    ){
        Id projectId = CopadoConstants.projectId;
        createAndDeployForwardPromotion(
                envs[0],
                projectId
        );
    }

    //create and deploy a promotion UP the flow
    public static void createAndDeployForwardPromotion(
            Id sourceEnvId,
            Id projectId
    ){
        copado__Promotion__c promotion = createForwardPromotion(sourceEnvId, projectId);

        //just to avoid re-querying
        queriedPromotion = promotion;

        promotion = attachUserStoriesBasedOnProject(promotion.Id);
        deployPromotion(promotion.Id,CopadoConstants.runLocalTests,false);
        //return promotion;
    }

    //create the promotion, but do not attach any stories
    public static copado__Promotion__c createForwardPromotion(
            Id sourceEnvId,
            Id projectId
    ){
        copado__Promotion__c promotion = new copado__Promotion__c();
        promotion.copado__Project__c = projectId;
        promotion.copado__Source_Environment__c = sourceEnvId;

        insert promotion;

        return promotion;
    }

    //attach stories to an existing promotion
    public static copado__Promotion__c attachUserStoriesBasedOnProject(
            String promId
    ){
        copado__Promotion__c promotion = getPromotion(promId);
        Set<Id> storyIds = CopadoUserStoryService.getUserStoriesToBePromoted(
                promotion.copado__Project__c,
                promotion.copado__Source_Environment__c
        ).keySet();

        List<copado__Promoted_User_Story__c> pus = new List<copado__Promoted_User_Story__c>();
        for(Id sid:storyIds){
            pus.add(new copado__Promoted_User_Story__c(
                    copado__User_Story__c = sid,
                    copado__Promotion__c = promotion.Id
            ));
        }
        insert pus;
        return promotion;
    }

    //deploy an existing promotion with a webhook
    @future(callout=true)
    public static void deployPromotion(
            String promId,
            String testLevel,
            Boolean isValidation
    ){
        copado__Promotion__c promotion = getPromotion(promId);

        String deploymentName = 'deploymentName=AutoDeployFrom'+promotion.copado__Source_Environment__r.Name + 'To' +promotion.copado__Destination_Environment__r.Name;
        String urlBase = CopadoConstants.webhookBase + CopadoConstants.deployPromotionBase;
        String testParameter = 'testLevel=' + testLevel;
        String apiKeyParameter = 'api_key=' + CopadoConstants.apiKey;
        String validationParameter = 'checkOnly=' + String.valueOf(isValidation);

        String hookURL = urlBase;
        hookURL += promotion.Id + '/process';
        hookURL += '?' + validationParameter;
        hookURL += '&' + testParameter;
        hookURL += '&' + apiKeyParameter;
        hookURL += '&' + deploymentName;

        callResponse = CopadoWebhookService.callWebhook('POST', hookURL, null);
        System.debug(callResponse);
        //return promotion;
    }

    public static copado__Promotion__c getPromotion(String promId){
        if(queriedPromotion == null || queriedPromotion.Id != promId){
            queriedPromotion = [
                    SELECT
                            Id,
                            Name,
                            copado__Source_Environment__c,
                            copado__Source_Environment__r.Name,
                            copado__Source_Org_Credential__c,
                            copado__Destination_Environment__c,
                            copado__Destination_Environment__r.Name,
                            copado__Destination_Org_Credential__c,
                            copado__Project__c,
                            copado__Release__c
                    FROM
                            copado__Promotion__c
                    WHERE Id = :promId
            ];
        }
        return queriedPromotion;
    }

}