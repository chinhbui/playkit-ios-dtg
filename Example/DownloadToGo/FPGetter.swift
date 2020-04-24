//
//  FPGetter.swift
//  DownloadToGo_Example
//
//  Created by chinhbui on 3/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import PlayKit
/*
staging : 4f70b43b-5969-4d7f-9446-f09a2e33f669
prod : b8420e05-9a89-4816-bf7d-9a06f080c8ab
*/
class FPGetter {
    static let shared = FPGetter()
    var cer : String = ""
    static let pHeader = "{\"userId\":\"b8420e05-9a89-4816-bf7d-9a06f080c8ab\",\"sessionId\":\"p1\",\"merchant\":\"fpt_ptv\"}"
    
    class func getCertificate(uri : String , callback: @escaping (Data?, TimeInterval, Error?) -> Void ) {
        guard let url = URL(string: uri) else { return }
        var request = URLRequest(url: url)
        
        // uDRM requires application/octet-stream as the content type.
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        
        request.setValue(FPGetter.pHeader.toBase64(),
                         forHTTPHeaderField: "x-dt-custom-data")
        
        request.httpMethod = "GET"
        
        
        let startTime = Date.timeIntervalSinceReferenceDate
        let dataTask = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                callback(nil, 0, FPSError.serverError(error, url))
                return
            }

            do {
                let endTime: Double = Date.timeIntervalSinceReferenceDate
                PKLog.debug("Got response in \(endTime-startTime) sec")
                
                guard let data = data, data.count > 0 else {
                    callback(nil, 0, FPSError.malformedServerResponse)
                    return
                }
                
                FPGetter.shared.cer = data.base64EncodedString()
                callback(data, 0, nil)
            }
        }
        dataTask.resume()
    }
}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    public func stringByAddingPercentEncodingForRFC3986() -> String? {
      let unreserved = "-._~?"
      let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
      allowedCharacterSet.addCharacters(in: unreserved)
      return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
    }
}

struct LicenseResponseContainer: Codable {
    var ckc: String?
    var persistence_duration: TimeInterval?
}
