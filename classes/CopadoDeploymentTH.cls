/**
 * Created by kheidt on 01/10/2018.
 */

public with sharing class CopadoDeploymentTH {

    public void createStoppingManualStep(List<copado__Deployment__c> deployments){

        //add counter to make sure it's only executed once
        CopadoConstants.CopadoDeploymentTriggerExecutionCounter ++;

        if(CopadoConstants.CopadoDeploymentTriggerExecutionCounter < 2) {
            System.debug('We will try to create Manual Steps');

            List<copado__Deployment__c> deploymentsToPause = new List<copado__Deployment__c>();
            for (copado__Deployment__c dpl : deployments) {
                if (dpl.Name.contains(CopadoConstants.pauseDeploymentString)) {

                    System.debug('Name contains pausing string ' + CopadoConstants.pauseDeploymentString);
                    deploymentsToPause.add(dpl);
                }
            }
            CopadoDeploymentStepService cdss = new CopadoDeploymentStepService();
            List<copado__Step__c> pausingSteps = cdss.createBlockingStep(deploymentsToPause);

            insert pausingSteps;
        } else{
            System.debug('This logic should only be run once');
        }
    }
}