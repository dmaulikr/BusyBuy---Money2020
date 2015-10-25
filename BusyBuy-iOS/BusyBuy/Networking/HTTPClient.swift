//
//  HTTPClient.swift
//  Networking
//
//  Created by Prasad Pamidi on 2/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias HttpSuccessHandler = (responseObject: AnyObject) -> ()
typealias HttpErrorHandler = (responseError: ErrorType) -> ()

let HTTP_ERROR_DOMAIN = "com.money2020.busybuy"
let HTTP_ERROR_CODE = 2015

class HTTPClient {
    private var alamo : Alamofire.Manager!
    private var baseURL: NSURL!
    var defaultEncoding: ParameterEncoding!
    
    private enum Router: URLStringConvertible {
        static let baseURLString = Configuration.getSecureBaseURL()!
        
        case Root
        case Custom(String)
 
        var URLString: String {
            let path: String = {
                switch self {
                case .Root:
                    return "/"
                case .Custom(let subpath):
                    return "/\(subpath)"
                }
            }()
            return Router.baseURLString + path
        }
    }
    
    static let client: HTTPClient = HTTPClient()
  
    init() {
        if let _ = Configuration.getSecureBaseURL(){
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            if let timeOutInterval = Configuration.getRequestTimeout() {
                configuration.timeoutIntervalForResource = NSTimeInterval(timeOutInterval)
            }
            
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                "apisandbox.dev.clover.com": .DisableEvaluation,
            ]

            alamo = Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
            defaultEncoding = .JSON
        }
    }
    
    func getResource(path: String!, parameters: [String : AnyObject]!, success: HttpSuccessHandler!, failure: HttpErrorHandler) {
        
        print("Request Path - \(Router.Custom(path).URLString)")
        print("Request Params - \(parameters)")
        
        alamo.request(.GET, Router.Custom(path), parameters: parameters, encoding: defaultEncoding, headers: nil).responseJSON { (response: Response<AnyObject, NSError>) -> Void in

            guard response.result.isSuccess else {
                failure(responseError: response.result.error ?? NSError(domain: HTTP_ERROR_DOMAIN, code: HTTP_ERROR_CODE, userInfo: ["error" : "empty result received"]))
                
                return
            }
            
            guard let value = response.result.value else {
                failure(responseError: response.result.error ?? NSError(domain: HTTP_ERROR_DOMAIN, code: HTTP_ERROR_CODE, userInfo: ["error" : "empty result received"]))
                
                return
            }
            
            success(responseObject: value)
        }
    }

    func postResource(path: String!, parameters: [String : AnyObject]!, success: HttpSuccessHandler!, failure: HttpErrorHandler) {
        print("Request Path - \(Router.Custom(path).URLString)")
        print("Request Params - \(parameters)")

        alamo.request(.POST, Router.Custom(path), parameters: parameters, encoding: defaultEncoding, headers: nil).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            
            guard response.result.isSuccess else {
                failure(responseError: response.result.error ?? NSError(domain: HTTP_ERROR_DOMAIN, code: HTTP_ERROR_CODE, userInfo: ["error" : "empty response received"]))
                
                return
            }
            
            guard let value = response.result.value else {
                failure(responseError: response.result.error ?? NSError(domain: HTTP_ERROR_DOMAIN, code: HTTP_ERROR_CODE, userInfo: ["error" : "empty response received"]))
                
                return
            }
            
            success(responseObject: value)
        }
    }
}