@isTest
public class MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requestsMap;
    
    public MultiRequestMock(Map<String, HttpCalloutMock> requestsMap) {
	    this.requestsMap = requestsMap;
    }
    
    public HTTPResponse respond(HTTPRequest req) {

	    // **** CALLOUT FOR OBJECT: Account   ****
	    if(req.getBody().contains('telephone3')){
	        // CALLOUT #1 (tokenRefreshed == FALSE)
		    if(CalloutsClass.tokenRefreshed == FALSE){
				if(req.getBody().contains('Error')){
					return requestsMap.get('2').respond(req);
				}
				if(req.getBody().contains('John Test')
						|| req.getBody().contains('ERROR B2B')){
					return requestsMap.get('2').respond(req);
				}
				System.debug('Test ' + req.getBody());
		        return requestsMap.get('1').respond(req);
		    }else{
			    // CALLOUT #3  (tokenRefreshed == TRUE)
			    return requestsMap.get('3').respond(req);
		    }
	     // CALLOUT #2  ( callout from  method: getToken() )
	    }else if(req.getBody().contains('client_id')){// REFRESH TOKEN --> REQUEST FROM getToken()
			    return requestsMap.get('2').respond(req);
	    }
	    // **** CALLOUT FOR OBJECT: Individual   *****
	    else if(req.getBody().contains('contactPreferences')){
		    // CALLOUT #3 (tokenRefreshed == FALSE)
		    if(CalloutsClass.tokenRefreshed == FALSE){
			    return requestsMap.get('3').respond(req);
		    }else {
			    // CALLOUT #4  (tokenRefreshed == TRUE)
			    return requestsMap.get('4').respond(req);
		    }
	    }
	    // **** CALLOUT FOR OBJECT: Subscriptions   *****
		// **** CALLOUT FOR OBJECT: winebank   *****
        else if(req.getBody().contains('reasonCode')) {
			// CALLOUT #2 (tokenRefreshed == FALSE)
			if(CalloutsClass.tokenRefreshed == FALSE){
				if(req.getBody().contains('Test')){
					return requestsMap.get('1').respond(req);
				}
				return requestsMap.get('3').respond(req);
			}else {
				// CALLOUT #4  (tokenRefreshed == TRUE)
				return requestsMap.get('4').respond(req);
			}
		}
		// **** CALLOUT FOR OBJECT: winebank   *****
        else if(req.getBody().contains('months')){
	        // **** CALLOUT FOR OBJECT: winebank   *****
	        return requestsMap.get('1').respond(req);
        }
		else if(req.getBody().contains('')) {
			// CALLOUT #2 (tokenRefreshed == FALSE)
			if(CalloutsClass.tokenRefreshed == FALSE){
				return requestsMap.get('1').respond(req);
			}else {
				// CALLOUT #5  (tokenRefreshed == TRUE)
				return requestsMap.get('5').respond(req);
			}
		} else if(req.getBody().contains('Test')) {
			// **** CALLOUT FOR OBJECT: individual   *****
			return requestsMap.get('3').respond(req);
		} else if(req.getBody().contains('leftOn')){
			// **** CALLOUT FOR OBJECT: winebank   *****
			return requestsMap.get('1').respond(req);
		}
	    else{
	        System.debug(' ######## CLASS: MultiRequestMock  ######  Exception: ' + 'HTTP callout not supported for test methods' );
	        throw new CalloutCustomException();
        }
    }
    
    public void addRequestMock(String url, HttpCalloutMock mock) {
        requestsMap.put(url, mock);
    }
}