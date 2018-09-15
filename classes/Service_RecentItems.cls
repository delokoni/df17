/**
 * Created by kheidt on 14/09/2018.
 */

public with sharing class Service_RecentItems {

    public static List<RecentlyViewed> getRecentlyViews(){
        return new List<RecentlyViewed>([
                SELECT ID, Name, Type
                FROM RecentlyViewed
                WHERE LastViewedDate != null
                ORDER BY LastViewedDate DESC
                LIMIT 15
        ]);
    }

}