Public Class MyCopadoService{


    public void myCopadoServiceMethod(){
        System.Debug('Hello Copado');

        List<Account> accts = new List<Account>();
        for(Integer i = 0; i<10; i++){
            accts = [SELECT Id FROM Account WHERE Name LIKE 'i%'];
        }
        
        if ( accts != null && accts.size() > 0){
            upsert accts;
        }
    
    }   
}