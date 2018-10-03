public class CopadoFlowStepService {
    
    //get DeploymentFlowStep linked to a specific environment
    public static List<copado__Deployment_Flow_Step__c> getFlowStepsForEnvironment(copado__Environment__c env){
        List<copado__Deployment_Flow_Step__c> flowSteps = new List<copado__Deployment_Flow_Step__c>(
            [
                SELECT
                        Id,
                        Name,
                        copado__Deployment_Flow__c,
                        copado__Branch__c,
                        copado__Destination_Branch__c,
                        copado__Destination_Environment__c,
                        copado__Source_Environment__c,
                        copado__Source_Environment__r.Name,
                        copado__Source_Environment__r.copado__Type__c
                FROM copado__Deployment_Flow_Step__c
                WHERE (
                    copado__Destination_Environment__c = :env.Id OR
                    copado__Source_Environment__c = :env.Id
                )
            ]
        );
        
        return flowSteps;
    }

    public static List<copado__Deployment_Flow_Step__c> getLowerEnvironmentSteps(copado__Environment__c destEnv){
        List<copado__Deployment_Flow_Step__c> flowSteps = new List<copado__Deployment_Flow_Step__c>(
            [
                SELECT
                        Id,
                        Name,
                        copado__Deployment_Flow__c,
                        copado__Branch__c,
                        copado__Destination_Branch__c,
                        copado__Destination_Environment__c,
                        copado__Source_Environment__c,
                        copado__Source_Environment__r.Name,
                        copado__Source_Environment__r.copado__Type__c
                FROM copado__Deployment_Flow_Step__c
                WHERE (
                        copado__Destination_Environment__c = :destEnv.Id
                )
            ]
        );

        return flowSteps;
    }
    
}