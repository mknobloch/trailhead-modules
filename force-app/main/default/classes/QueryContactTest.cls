@isTest
private class QueryContactTest {

	@testSetup
	static void dataCreation() {
		Account account = TestFactory.getAccount('Muddy Waters Inc.', true);
		Contact contact = TestFactory.getContact(account.Id, 'Muddy', 'Waters', 'Agent', true);
	}

	@isTest
	static void testGetContactId() {
        Id contactId;

		Test.startTest();
			contactId = QueryContact.getContactId('Waters', 'Agent');
		Test.stopTest();

		Assert.isTrue(String.isNotBlank(String.valueOf(contactId)), 'Id from the Contact created in Test Setup should be found');
	}

	@isTest
	static void testGetContactIDWithBinds() {
        Id contactId;

        Map<String, Object> bindVars = new Map<String, Object>{'lastName' => 'Waters', 'title' => 'Agent'};

		Test.startTest();
			contactId = QueryContact.getContactIDWithBinds(bindVars);
		Test.stopTest();

		Assert.isTrue(String.isNotBlank(String.valueOf(contactId)), 'Id from the Contact created in Test Setup should be found');
	}
}