/**
 * Created by kheidt on 01/10/2018.
 */

trigger CopadoPromotionTR on copado__Promotion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    CopadoAutoBackPromoteService cabp = new CopadoAutoBackPromoteService();

    if(Trigger.isBefore){
        //no logic yet
    } else if(Trigger.isAfter){

        if(Trigger.isUpdate){
            CopadoPromotionTH cpth = new CopadoPromotionTH();
            cpth.createPromotionsForLowerEnvironments(Trigger.new[0]);

        }
    }

}