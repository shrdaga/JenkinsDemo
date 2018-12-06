@RestResource(urlMapping='/Accounts/*/contacts')
global with sharing class AccountManager {
    @HttpGet
    global static Account getAccount() {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.VIN_Number__c = 'testVinNumber';
        RestRequest req = RestContext.request;
        String accId = req.requestURI.substringBetween('Accounts/', '/contacts');
        Account acc = [
            SELECT Id, Name, (SELECT Id, Name FROM Contacts)
            FROM Account WHERE Id = :accId
        ];
        return acc;
    }


    public static void testThisMethod(){
        System.debug('');
    }
}