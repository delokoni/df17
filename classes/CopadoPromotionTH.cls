/**
 * Created by kheidt on 01/10/2018.
 */

public with sharing class CopadoPromotionTH {

    public void createPromotionsForLowerEnvironments(copado__Promotion__c promotion){
        if(promotion.copado__Status__c == CopadoConstants.successfulPromotionStatus){
            CopadoAutoBackPromoteService cabps = new CopadoAutoBackPromoteService(promotion);
            cabps.createBackPromotionsForLowerOrgs();
        }
    }

}