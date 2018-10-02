/**
 * Created by kheidt on 01/10/2018.
 */

public with sharing class CopadoDeploymentStepService {

    public List<copado__Step__c> createBlockingStep(List<copado__Deployment__c> deployments){
        List<copado__Step__c> steps = new List<copado__Step__c>();

        for(copado__Deployment__c dpl : deployments){
            copado__Step__c step = new copado__Step__c();
            step.Name = 'Pause Deployment Execution';
            step.copado__Type__c = 'Manual Task';
            step.copado__Order__c = -1;
            step.copado__Status__c = 'Not started';
            step.copado__Deployment__c = dpl.Id;
            step.copado__dataJson__c = CopadoConstants.pauseManualTaskJSON;
            steps.add(step);
        }

        System.debug('pausing steps to be created: ' + steps);
        return steps;
    }
}