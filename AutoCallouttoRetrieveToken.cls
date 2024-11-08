/*

Author : Irwan Rahman Sunarto
Last Update : 08/11/2024

Main class for AutoCallouttoRetrieveToken
Used for getting the access token and save it in the Custom Settings inside Setup Page in Salesforce.
Since text field in Custom Settings is limited to 255 char, then this code is configured to divide the length if the retrieved code is more than 255 char.

Please change AuthSandbox and AuthProd according to your Auth code.
Please use AutoCallouttoRetrieveToken_UnitTest for the Unit Test

*/

Global class AutoCallouttoRetrieveToken implements schedulable{
    
    global void execute(SchedulableContext sc) {
            getProdTokenAndUpdateCustomSettingsAsync();
        }
    
        @future(callout=true)
        public static void getProdTokenAndUpdateCustomSettingsAsync() {
            // Custom Settings Name
            String customSettingsName = 'ThridPartyToken__c';
            ThridPartyToken__c settings = ThridPartyToken__c.getOrgDefaults();
    
            String authheader;
            if (settings != null) {
                    String authUrl = settings.URLEndpoint__c;
                    String authusername = settings.Username__c;
                    String authpassword = settings.Password__c;
                    String requestBody = String.format('username={0}&password={1}&grant_type=password', 
                                   new List<String>{authusername, authpassword});
                if(settings.Sanboxed__c == true){
                    authheader = 'Basic AuthSandbox';
                } else {
                    authheader = 'Basic AuthProd';
                }
    
                HttpRequest request = new HttpRequest();
                request.setEndpoint(authUrl);
                request.setMethod('POST');
                request.setHeader('Authorization', 'Basic ' + authheader);
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setBody(requestBody);
    
                Http http = new Http();
                HttpResponse response = http.send(request);
    
                if (response.getStatusCode() == 200) {
                    Map<String, Object> authDetails = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    
                    String accessToken = (String) authDetails.get('access_token');
                    String tokenPart1 = accessToken.substring(0, 255);
                    String tokenPart2 = accessToken.substring(255, Math.min(accessToken.length(), 510));
    
                    settings.Auth1Prod__c = tokenPart1;
                    settings.Auth2Prod__c = tokenPart2;
    
                    upsert settings;
                } else {
                    System.debug('Error in HTTP request. Status Code: ' + response.getStatusCode());
                    System.debug('Response Body: ' + response.getBody());
                }
            } else {
                System.debug('Default organization-level Custom Settings not found. Please check the configuration.');
            }
        }
    }