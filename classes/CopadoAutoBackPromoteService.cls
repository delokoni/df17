/**
 * Created by kheidt on 07/09/2018.
 */

public with sharing class CopadoAutoBackPromoteService {

    public Set<Id> envIds = new Set<Id>();
    public copado__Promotion__c finishedPromotion;
    public List<Id> newPromotionIds = new List<Id>();

    //mimic standard Constructor
    public CopadoAutoBackPromoteService(){}

    //Constructor to be called by a trigger
    public CopadoAutoBackPromoteService(
            copado__Promotion__c inputPromotion
    ){
        finishedPromotion = inputPromotion;
    }

    public void createBackPromotionsForLowerOrgs(){

        this.getTargetOrgIds();
        this.createNewPromotions();
        this.addStoriesFromOtherPromotions();

        //set flag in order to stop deployment execution upon creation
        CopadoPromotionService.stopDeploymentExecution = true;

        this.fireDeploymentCreationForNewPromotions();
    }

    //check for lower orgs
    public void getTargetOrgIds() {
        //reuse code to get the environment record
        System.debug(finishedPromotion);
        copado__Environment__c destEnvironment = CopadoEnvironmentService.getEnvironmentByOrgId(
                finishedPromotion.copado__Destination_Org_Credential__c
        );

        //get lower steps and their source environments
        List<copado__Deployment_Flow_Step__c> flowSteps = CopadoFlowStepService.getLowerEnvironmentSteps(destEnvironment);
        for(copado__Deployment_Flow_Step__c step : flowSteps){
            if(step.copado__Source_Environment__c != finishedPromotion.copado__Source_Environment__c) {
                if(step.copado__Source_Environment__r.copado__Type__c != CopadoConstants.scratchOrgType) {
                    this.envIds.add(step.copado__Source_Environment__c);
                    System.Debug('Environment Added: ' + step.copado__Source_Environment__r.Name);
                }
            }
        }
    }

    //create back promotion for all lower orgs
    public void createNewPromotions() {
        List<copado__Promotion__c> newPromotions = CopadoPromotionService.createBackwardPromotions(
                new List<Id>(this.envIds), this.finishedPromotion.copado__Project__c
        );
        System.debug('we will create the following new promotions' + newPromotions.size() + ' | ' + newPromotions);
        insert newPromotions;

        for(copado__Promotion__c prom : newPromotions){
            newPromotionIds.add(prom.Id);
        }

    }

    //clone user stories from original promotion to new promotions
    public void addStoriesFromOtherPromotions(){
        List<copado__Promoted_User_Story__c> newPus = CopadoPromotionService.attachStoriesFromPromotions(
                new List<Id>{finishedPromotion.Id},
                newPromotionIds
        );
        insert newPus;
    }

    //fire promotion deployment creation
    public void fireDeploymentCreationForNewPromotions(){

        //by the time this is executed, the User Story Service should have run the lines to check if stories have apex code.
        String testlevel = CopadoUserStoryService.hasApexCode == true ? CopadoConstants.runSelectedTests : CopadoConstants.noTestRun;

        //ensure the tag is added correctly
        CopadoPromotionService.stopDeploymentExecution = true;

        for(Id promoId : newPromotionIds){
            CopadoPromotionService.deployPromotion(
                    String.valueOf(promoId),
                    testlevel,
                    false
            );
        }
    }
}