@isTest
public class TestDataFactory {
    public static User createAdminUser(){
        Profile adminProfile = Srvc_User.getProfile('System Administrator');
        User newUser = new User();
        newUser.ProfileId = adminProfile.Id;
        newUser.FirstName = 'Alois';
        newUser.LastName = 'Admin';
        newUser.email = 'admin@aa.test';
        newUser.Username = 'admin@aa.test';
        newUser.Alias = 'aadmin';
        newUser.CommunityNickname = 'aadmin';
        newUser.LocaleSidKey = 'es_ES';
        newUser.emailencodingkey='UTF-8';
        newUser.languagelocalekey='en_US';
        newUser.TimeZoneSidKey='Europe/Rome';
        return newUser;
    }
    
    public static User createStandardUser(){
        Profile standardProfile = Srvc_User.getProfile('Standard User');
        User newUser = new User();
        newUser.ProfileId = standardProfile.Id;
        newUser.FirstName = 'Steven';
        newUser.LastName = 'Standard';
        newUser.email = 'standard@aa.test';
        newUser.Username = 'standard@aa.test';
        newUser.Alias = 'standard';
        newUser.CommunityNickname = 'stand';
        newUser.LocaleSidKey = 'es_ES';
        newUser.emailencodingkey='UTF-8';
        newUser.languagelocalekey='en_US';
        newUser.TimeZoneSidKey='Europe/Rome';
        
        return newUser;
    }
    
    public static Account createAccount(String name){
        Account acct = new Account();
        acct.Name = name;
        
        return acct;
    }
    
    public static Opportunity createOppty(Account acct, String name){
        Opportunity oppty = new Opportunity();
        oppty.Name = name;
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Qualification';
        oppty.CloseDate = Date.today() + 30;
        
        return oppty;
    }
}