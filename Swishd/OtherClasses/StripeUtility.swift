

import Foundation
import Stripe


struct StripeTools {
    
    //store stripe secret key
    private var stripeSecret = "sk_test_5eFIVHSywYvbfvJyMW1CX1XK"
    
    //generate token each time you need to get an api call
    func generateToken(card: STPCardParams, completion: @escaping (STPToken?, Error?) -> Void) {
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            completion(token, error)
        }
    }
    
    func getBasicAuth() -> String{
        return "Bearer \(self.stripeSecret)"
    }
}


class StripeUtil {
    
    static var shared = StripeUtil()
    var stripeTool = StripeTools()
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    
    //createUser
    func createUser(completion: @escaping (Any?, Error?) -> Void) {
        
        //request to create the user
        var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/customers")!)
        
        //params array where you can put your user informations
        var params = [String:String]()
        params["email"] = _user.email
        
        //transform this array into a string
        var str = ""
        params.forEach({ (key, value) in
            str = "\(str)\(key)=\(value)&"
        })
        
        //basic auth
        request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
        
        //POST method, refer to Stripe documentation
        request.httpMethod = "POST"
        
        request.httpBody = str.data(using: String.Encoding.utf8)
        
        //create request block
        self.dataTask = self.defaultSession.dataTask(with: request) { (data, response, error) in
            
            //get returned error
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            else if let httpResponse = response as? HTTPURLResponse {
                //you can also check returned response
                if(httpResponse.statusCode == 200) {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        DispatchQueue.main.async {
                            completion(json, nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        
        //launch request
        self.dataTask?.resume()
    }
    
    //create card for given user
    func createCard(stripeId: String, card: STPCardParams, completion: @escaping (Any?, Error?) -> Void) {
        
        stripeTool.generateToken(card: card) { (token, error) in
            if let tok = token {
                var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/customers/\(stripeId)/sources")!)
                
                //token needed
                var params = [String:String]()
                params["source"] = tok.tokenId
                
                var str = ""
                params.forEach({ (key, value) in
                    str = "\(str)\(key)=\(value)&"
                })
                
                //basic auth
                request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
                
                request.httpMethod = "POST"
                
                request.httpBody = str.data(using: String.Encoding.utf8)
                
                self.dataTask = self.defaultSession.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }else if let httpResponse = response as? HTTPURLResponse {
                        if (httpResponse.statusCode == 200) {
                            if let data = data {
                                let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                DispatchQueue.main.async {
                                    completion(json, nil)
                                }
                            }else{
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                completion(nil, error)
                            }
                        }
                    }else {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
                self.dataTask?.resume()
            }else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    //get user card list
    func getCardsList(completion: @escaping (Any?, Error?) -> ()) {
        
        //request to create the user
        var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/customers/\(_user.stripeCustomerId)/sources?object=card")!)
        
        //basic auth
        request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
        
        //POST method, refer to Stripe documentation
        request.httpMethod = "GET"
        
        //create request block
        self.dataTask = self.defaultSession.dataTask(with: request) { (data, response, error) in
            
            //get returned error
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            else if let httpResponse = response as? HTTPURLResponse {
                //you can also check returned response
                if (httpResponse.statusCode == 200) {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        DispatchQueue.main.async {
                            completion(json, nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        //launch request
        self.dataTask?.resume()
    }
}
