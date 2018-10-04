/**
 * Created by kheidt on 01/10/2018.
 */

public with sharing class CopadoDeploymentTH {

    public void createStoppingManualStepUpdate(
            List<copado__Deployment__c> oldDeployments,
            List<copado__Deployment__c> newDeployments)
    {
        //check if the update contained a name change
        List<copado__Deployment__c> scopeDeployments = new List<copado__Deployment__c>();
        for(Integer i = 0; i < newDeployments.size(); i++){
            //if name has changed
            if(oldDeployments[i].Name != newDeployments[i].Name){
                System.debug('name has changed');
                //if the old name did not, but the new name contains the pausing string
                if(
                    !oldDeployments[i].Name.contains(CopadoConstants.pauseDeploymentString) &&
                    newDeployments[i].Name.contains(CopadoConstants.pauseDeploymentString)
                ){
                    System.debug('New name has string');
                    scopeDeployments.add(newDeployments[i]);
                }
            }
        }
        this.createStoppingManualStep(scopeDeployments);
    }

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
            List<copado__Step__c> pausingSteps = cdss.createBlockingStep(deploymentsToPause,true);

            insert pausingSteps;
        } else{
            System.debug('This logic should only be run once');
        }
    }
}