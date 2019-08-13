public with sharing class InterfaceClass {

	static final String DEFAULT_CONTENT_TYPE = 'application/json';
	static final String CONTENT_TYPE_HEADER = 'Content-Type';
	static final String AUTHORIZATION_HEADER = 'Authorization';
	public static HttpRequest saveRequest;
	public InterfaceClass() {
	}

	public static HttpResponse post(String body, Map<String,String> connectionDetails)	{
		HttpRequest request = CreateRequest('POST',body,connectionDetails);
		return send(request);
	}

	public static HttpResponse put(String body, Map<String,String> connectionDetails)	{
		HttpRequest request = CreateRequest('PUT',body,connectionDetails);
		System.debug('request');
		System.debug(request);
		return send(request);
	}	

    public static HttpResponse get(String body, Map<String,String> connectionDetails)   {
        HttpRequest request = CreateRequest('GET',body,connectionDetails);
        return send(request);
    }    

     public static HttpResponse send(HttpRequest request){
        HttpResponse response = new HttpResponse();
        Http         http     = new Http();
        try{
            //Making call to external REST API
            response = http.send(request);
            system.debug(' ===== CLASS: InterfaceClass  ===== Response body: ===== '+response.getbody()+' ==getStatusCode== '+response.getStatusCode());
        }catch(Exception e){
            System.debug('Error::'+e.getMessage());
            CalloutRecord.insertCalloutRecord('InterfaceClass', 'send', request, response,'Error',e.getMessage()+ '\n'+ e.getStackTraceString(),null);
        }
        return response;
     }	

	private static HttpRequest CreateRequest(String httpMethod, String body,Map<String,String> connectionDetails)	{
		system.debug(' ***** CLASS: InterfaceClass  connectionDetails ' + connectionDetails);

		HttpRequest request = new HttpRequest();
        request.setHeader(CONTENT_TYPE_HEADER, DEFAULT_CONTENT_TYPE);
        request.setHeader(AUTHORIZATION_HEADER,connectionDetails.get('Token'));
        if(httpMethod != 'GET'){request.setbody(body);}

        request.setEndpoint(connectionDetails.get('EndPoint'));
        request.setMethod(httpMethod);
        Http http = new Http();	
        saveRequest = request;
		system.debug(' ***** CLASS: InterfaceClass  >>>>> Request body: <<<<<'+request.getbody()+' >>>getEndpoint<<< '+request.getEndpoint());
		return request;
	}
}