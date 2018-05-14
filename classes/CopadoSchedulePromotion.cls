/**
 * Created by kheidt on 13/05/2018.
 */

global class CopadoSchedulePromotion implements Schedulable {

    @testVisible private Id environmentId;

    global CopadoSchedulePromotion(Id envId){
        environmentId = envId;
    }

    global void execute (SchedulableContext sc){
        CopadoPromotionService.createAndDeployPromotionForProject(new List<Id>{environmentId});
    }
}