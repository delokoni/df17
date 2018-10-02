/**
 * Created by kheidt on 01/10/2018.
 */

trigger CopadoDeploymentTR on copado__Deployment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    //instanciate trigger handler to control instances
    CopadoDeploymentTH cdth = new CopadoDeploymentTH();

    if(Trigger.isBefore){
        /**
        * no logic yet
        **/
        System.debug('no before logic yet');
    }
    if(Trigger.isAfter) {
        System.debug('enter after logic');
        if (Trigger.isUpdate || Trigger.isInsert){

            cdth.createStoppingManualStep(Trigger.new);
        }
    }
}