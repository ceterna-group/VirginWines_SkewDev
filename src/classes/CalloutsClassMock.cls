@isTest
public class CalloutsClassMock implements HttpCalloutMock{
	protected Integer code;
	protected String status;
	protected String bodyAsString;
	protected Map<String, String> responseHeaders;
	
	// CONSTRUCTOR
	public CalloutsClassMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.bodyAsString = body;
		this.responseHeaders = responseHeaders;
	}
	
	// HttpCalloutMock Class must implement method 'respond' to return a fake HttpResponse:
	public HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
	    res.setStatusCode(code);
        res.setStatus(status);
	    res.setbody(bodyAsString);
		if (responseHeaders != null) {
			for (String key : responseHeaders.keySet()) {
				res.setHeader(key, responseHeaders.get(key));
			}
		}
        return res;
    }
}