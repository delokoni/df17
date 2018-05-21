public class Srvc_User {
    
    private static Map<String, Object> registry = new Map<String, Object>();
    
    public static User getUser(Id userId){
        User thisUser = new User();
        if(registry.get(userId)!= null){
            thisUser = (User) registry.get(userId);
        } else {
            thisUser = queryUser(userId);
            registry.put(userId, thisUser);
        }
        return thisUser;
    }
    
    public static Profile getProfile(String profileName){
        if(registry.get(profileName)!= null){
            return (Profile) registry.get(profileName);
        } else{
            Profile thisProfile = queryProfile(profileName);
            registry.put(profileName, thisProfile);
            return thisProfile;
        }
        
    }
    
    /** queries and more stuff **/
    
    private static Profile queryProfile(String profileName){
        return [
            SELECT
            	Id,
            	Name
            FROM
            	Profile
            WHERE
            	Name = :profileName
            LIMIT
            	1
        ];
    }
    
    private static User queryUser(Id userId){
        return [
            SELECT
            	Id,
            	Name
            FROM 
            	User
            WHERE
            	Id = :userId
        ];
    }
}