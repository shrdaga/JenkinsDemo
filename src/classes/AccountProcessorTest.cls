/**
 */

@IsTest
private class AccountProcessorTest {
    static testMethod void testBehavior() {
        Test.startTest();
        Account account = new Account(Name = 'Test123');
        insert account;
        Account account1 = [SELECT Id FROM Account LIMIT 1];
        Contact contact = new Contact(AccountId = account1.Id, LastName = 'LastName');
        insert contact;

        List<Id> accIds = new List<Id>();
        accIds.add(account1.Id);
        //AccountProcessor.countContacts(accIds);
        Test.stopTest();
    }
}