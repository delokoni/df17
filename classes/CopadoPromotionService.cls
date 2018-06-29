/**
 * Created by kheidt on 17/04/2018.
 * to invoque a promotion deployment through another apex class: CopadoPromotionService.createAndDeployForwardPromotion('NameOfEnvironment', 'NameOfProject');
 * to invoque a promotion validation through another apex class: CopadoPromotionService.createAndValidateForwardPromotion('NameOfEnvironment', 'NameOfProject');
 */

public with sharing class CopadoPromotionService {

    public static copado__Promotion__c queriedPromotion = new copado__Promotion__c();
    public static HttpResponse callResponse;
   	public static Boolean hasApexCode = false;   
    
    /**
     * create and deploy a promotion UP the flow. parameters are the name of an environment and a project
     **/
    public static void createAndDeployForwardPromotion(
            String sourceEnvName, 
            String prjName 
    ){
		
        Id sourceEnvId = CopadoEnvironmentService.getEnvironementByName(sourceEnvName).Id;
        Id projectId = CopadoProjectService.getProjectByName(prjName).Id;
        String testlevel = hasApexCode == true ? CopadoConstants.runSelectedTests : CopadoConstants.noTestRun; 
        
        createAndValidatedPromotionBase(
        	sourceEnvId,
            projectId,
            testLevel,
            false
        );
    }
    
    /**
     * create and deploy a validation UP the flow. parameters are the name of an environment and a project
     **/
    public static void createAndValidateForwardPromotion(
            String sourceEnvName,
            String prjName
    ){
		
        Id sourceEnvId = CopadoEnvironmentService.getEnvironementByName(sourceEnvName).Id;
        Id projectId = CopadoProjectService.getProjectByName(prjName).Id;
        String testlevel = hasApexCode == true ? CopadoConstants.runSelectedTests : CopadoConstants.noTestRun; 
        
        createAndValidatedPromotionBase(
        	sourceEnvId,
            projectId,
            testLevel,
            true
        );
    }
    
    public static void createAndValidatedPromotionBase(
            Id sourceEnvId, 
            Id projectId, 
        	String testLevel,
        	Boolean isValidation
    ){
        copado__Promotion__c promotion = createForwardPromotion(sourceEnvId, projectId);

        //just to avoid re-querying
        queriedPromotion = promotion;

        promotion = attachUserStoriesBasedOnProject(promotion.Id);
        deployPromotion(promotion.Id,testLevel,isValidation);
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
        Map<Id, copado__User_Story__c> stories = CopadoUserStoryService.getUserStoriesToBePromoted(
                promotion.copado__Project__c,
                promotion.copado__Source_Environment__c
        );
        Set<Id> storyIds = stories.keySet();
        
		Boolean listHasApexCode = false;
        List<copado__Promoted_User_Story__c> pus = new List<copado__Promoted_User_Story__c>();
        for(Id sid:storyIds){
            pus.add(new copado__Promoted_User_Story__c(
                    copado__User_Story__c = sid,
                    copado__Promotion__c = promotion.Id
            ));
            
            //check if some stories have classes to set the test level accordingly later on
            if(stories.get(sid).copado__Has_Apex_Code__c == true){
                listHasApexCode = true;
            }            
        }
        
      	hasApexCode = listHasApexCode;
        
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