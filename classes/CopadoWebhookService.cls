/**
 * Created by kheidt on 19/03/2018.
 */

public class CopadoWebhookService {

    public static HttpResponse runStaticCodeAnalysisOnUserStory(String usId){
        //get the user story to gather the required parameters
        copado__User_Story__c us = [
                SELECT Id, Name, copado__Org_Credential__c, copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__c, copado__Project__r.copado__Deployment_Flow__r.copado__Static_Code_Analysis_Settings__c
                FROM copado__User_Story__c
                WHERE Id = :usId
                LIMIT 1
        ];

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
        return callWebhook('POST', webhookURL, webhookBody);
    }

    public static HttpResponse callWebhook(String requestMethod, String url, String body){

        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod( requestMethod);
        request.setEndpoint(url);
        if(body != null){
            request.setBody(body);

            //if a body is provided, we set the content type to application/json. this is done in the
            request.setHeader('Content-Type','application/json');
        }

        HttpResponse response = h.send(request);
        return response;
    }
}