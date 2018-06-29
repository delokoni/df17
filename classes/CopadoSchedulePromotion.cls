/**
 * Created by kheidt on 13/05/2018.
 */

global class CopadoSchedulePromotion implements Schedulable {

    @testVisible private String environmentName;
    @testVisible private String projectName;
    
    global CopadoSchedulePromotion(String envName, String prjName){
        environmentName = envName;
        projectName = prjName;
    }

    global void execute (SchedulableContext sc){
        CopadoPromotionService.createAndDeployForwardPromotion(environmentName,projectName);
    }
}