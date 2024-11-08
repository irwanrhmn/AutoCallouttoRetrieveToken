/*

Author : Irwan Rahman Sunarto
Last Update : 08/11/2024

Unit Test for AutoCallouttoRetrieveToken

*/
@isTest
private class AutoCallouttoRetrieveToken_UnitTest {

    @isTest
    static void testAutoCallouttoRetrieveToken() {
        ThridPartyToken__c testSettings = new ThridPartyToken__c(
            Name = 'Test Settings',
            Auth_URL__c = 'https://example.com/auth'
        );
        insert testSettings;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String jobId = System.schedule('Test AccessTokenScheduler', '0 0 * * * ?', new AutoCallouttoRetrieveToken());
        Test.stopTest();

        System.abortJob(jobId);
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);

            String mockAccessToken = 'A'.repeat(255); // Adjust the length as needed

            response.setBody('{"access_token": "' + mockAccessToken + '"}');
            return response;
        }
    }
}