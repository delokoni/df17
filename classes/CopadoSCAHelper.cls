/**
 * Created by kheidt.
 */

public with sharing class CopadoSCAHelper {
    public static HttpResponse runStaticCodeAnalysisOnUserStory(String usId){
        //get the user story to gather the required parameters
        copado__User_Story__c us = CopadoUserStoryService.getUserStory(usId);

        //construct URL parameters
        String apiParameter = 'api_key='+ CopadoConstants.apiKey;
        String usIdParameter = 'userStoryId=' + usId;
        String orgCredParameter = us.copado__Org_Credential__c;
        String settingsIdParameter = 'settingsId=' + us.copado__Project__r.copado__Deployment_Flow__r.copado__Static_Code_Analysis_Settings__c;
        String repoParameter = 'repositoryId='+us.copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__c;
        String branchNameParameter = 'branch=feature/' + us.Name;

        //Construct Endpoint URL
        String webhookURL = CopadoConstants.webhookBase + CopadoConstants.analyseStaticCodeBase;
        webhookURL += orgCredParameter;
        webhookURL += '?' + apiParameter;
        webhookURL += '&' + usIdParameter;
        webhookURL += '&' + repoParameter;
        webhookURL += '&' + branchNameParameter;
        webhookURL += '&' + settingsIdParameter;

        System.debug('endpoint: ' + webhookURL);

        //Get the webhook body and convert it to a JSON
        CopadoAttachmentService cas = new CopadoAttachmentService();
        String webhookBody = JSON.serialize(cas.getApexClassesFromUserStoryAttachments(usId));

        //convert body into required format
        webhookBody = '{ \"gitMetadata\":' + webhookBody+ ',\"metadata\":' + webhookBody +'}';
        System.debug('body: ' + webhookBody);

        //fire the callout
        return CopadoWebhookService.callWebhook('POST', webhookURL, webhookBody);
    }
}