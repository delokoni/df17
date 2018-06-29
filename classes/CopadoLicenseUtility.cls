public class CopadoLicenseUtility {
        
    public CopadoLicenseUtility(){
        copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI(); 
        System.debug(copadoGlobalAPI.getLicenseInformation()); 
        System.debug(copadoGlobalAPI.listCopadoLicenses()[0]);
    }
    
    public Integer getNumberOfAvailableCCM(){
        return null;

    }
    
    public List<Id> getUsersWithCCM(){
        return null;
    }
    
    public void removeLicenseFromUser(Id userId, String licenseType){
        
    }
    
    public void addLicenseToUser(Id userId, String licenseType){
        
    }
}