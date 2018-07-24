/**
 * Created by kheidt.
 */

public  class CopadoAttachmentService {

    public static List<CopadoWrapper.MetadataItem> items = new List<CopadoWrapper.MetadataItem>();

    public List<String> getApexClassesFromUserStoryAttachments(String usId){

        List<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE Name = 'Git MetaData' AND ParentId = :usId];

        Set<String> gitClasses = new Set<String>();

        if(!attachments.isEmpty()) {
            String attBody = '{ \"att\": ' + attachments[0].Body.toString() + '}';
            System.debug('attachment: ' + attBody);
            Map<String, Object> gitSelections =  (Map<String, Object>)JSON.deserializeUntyped(attBody);
            CopadoWrapper cw = CopadoWrapper.parse(attBody);


            System.debug('git Metadata: ' + cw);
            for(CopadoWrapper.MetadataItem mi : cw.att){
                if(mi.t == 'ApexClass' || mi.t == 'ApexTrigger'){
                    gitClasses.add(mi.n);
                    items.add(mi);
                }
            }
        }
        return new List<String>(gitClasses);
    }
}