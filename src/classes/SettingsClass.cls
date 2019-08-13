public with sharing class SettingsClass {
    public SettingsClass () {

    }

    public static final String TOKEN_NOT_NECESSARY = 'Token Not Necessary';
    public static final String TOKEN_REFRESH = 'Token Refresh';
    public static final String BEGIN_PHRASE = 'Token';

    public static Mantiki__c getSettings(){

        Mantiki__c mantikiSettings = Mantiki__c.getOrgDefaults();     
        try{
            if(mantikiSettings.Token__c == null)    {
                mantikiSettings = getToken(mantikiSettings);
            }else{
                if(mantikiSettings.Finish__c < system.now())    {
                    mantikiSettings = getToken(mantikiSettings);
                }else{
                    mantikiSettings.Message__c = TOKEN_NOT_NECESSARY;
                }
            }  
        }catch(Exception e){
            System.debug('ERRORRR');
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecord('SettingsClass', 'getSettings', null, null,'Error',e.getMessage()+ '\n'+ e.getStackTraceString(),null);
        }            

        return mantikiSettings;
    }

    public static Mantiki__c getToken(Mantiki__c mantikiSettings)   {
        try{
            mantikiSettings.Message__c = TOKEN_REFRESH;
            HttpRequest req = new HttpRequest();

            String payload = 'client_id='+EncodingUtil.urlEncode(mantikiSettings.Client_Id__c,'UTF-8');
            payload += '&client_secret='+EncodingUtil.urlEncode(mantikiSettings.Client_Secret__c,'UTF-8');      
            payload += '&grant_type='+EncodingUtil.urlEncode(mantikiSettings.Grant_Type__c,'UTF-8');

            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setbody(payload);
            req.setEndpoint(mantikiSettings.End_Point__c+mantikiSettings.getToken__c);  
            req.setMethod('POST');

            System.debug('reponse settings class123');
            Http http = new Http();
            HTTPResponse response = new HttpResponse();
            response = http.send(req);
            
            System.debug('reponse settings class');
            System.debug(response);
            if(response.getStatusCode() >= 400 && response.getStatusCode()<=600)    {
                mantikiSettings.Message__c = 'Error on Token Refresh. Connection Status Code = '+response.getStatusCode()+' Status = '+response.getStatus();
                mantikiSettings.Status_Code__c = response.getStatusCode();
            }else{
                ResponseOauth responseValue = new ResponseOauth();
                responseValue = (ResponseOauth)System.JSON.deserialize(response.getBody(), ResponseOauth.class);
                
                mantikiSettings.Token__c = responseValue.access_token;
                mantikiSettings.Begin__c = system.now();
                mantikiSettings.Finish__c = mantikiSettings.Begin__c.addSeconds(responseValue.expires_in-3600);
                
            }
        }catch(Exception e){
            System.debug('Error::IN'+e.getMessage());
            CalloutRecord.insertCalloutRecord('SettingsClass', 'getToken', null, null,'Error',e.getMessage()+ '\n'+ e.getStackTraceString(),null);
        }

        System.debug('return');
        System.debug(mantikiSettings);
        return mantikiSettings;
    }

    public class ResponseOauth{
        ResponseOauth(){

        }
        public String access_token {get;set;}
        public Integer expires_in {get;set;}
    }
}