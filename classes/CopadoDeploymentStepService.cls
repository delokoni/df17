/**
 * Created by kheidt on 01/10/2018.
 */

public with sharing class CopadoDeploymentStepService {

    public List<copado__Step__c> createBlockingStep(
            List<copado__Deployment__c> deployments,
            Boolean isBeforeDeployment
    ){
        List<copado__Step__c> steps = new List<copado__Step__c>();

        for(copado__Deployment__c dpl : deployments){
            copado__Step__c step = new copado__Step__c();
            step.Name = 'Pause Execution';
            if(isBeforeDeployment){
                step.Name += ' Before Deployment';
            } else{
                step.Name += ' After Deployment';
            }
            step.copado__Type__c = 'Manual Task';

            //set step number according to before or after deployment
            //-1 and 900 to make sure the step is at the beginning or end of the list
            step.copado__Order__c = isBeforeDeployment == true ? -1 : 911;
            step.copado__Status__c = 'Not started';
            step.copado__Deployment__c = dpl.Id;
            step.copado__dataJson__c = CopadoConstants.pauseManualTaskJSON;
            steps.add(step);
        }

        System.debug('pausing steps to be created: ' + steps);
        return steps;
    }
}