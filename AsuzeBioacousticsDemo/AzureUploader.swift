//
//  AzureUpload.swift
//  AsuzeBioacousticsDemo
//
//  Created by acr on 21/07/2015.
//  Copyright (c) 2015 University of Southampton. All rights reserved.
//

import Foundation

extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        if let jsonData = data {
            
            return NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        
        } else {
            
            return nil
        
        }
        
    }
    
}

class AzureUploader {
        
    var delegate:AzureUploaderDelegate
    
    let URL_STRING:String = "https://ussouthcentral.services.azureml.net/workspaces/7244637e0ef043729404d661fe6cdef3/services/91a3a3d8d6044675ac9557dd82aec8ef/execute?api-version=2.0&details=true"
    
    let API_KEY = "qZJhuNSWgEJXR852DSKaG7ZXPLWec2S1sJut47450ELc/OIxjWhRMZ8cNUJrN1KYP9boFeApiOIGO8MrvXa5FA=="
    
    let data_start = "{\"Inputs\": {\"Audio\": {\"ColumnNames\": [\"Samples\"],\"Values\": ["
    let data_end = "]}},\"GlobalParameters\":{"

    init(delegate: AzureUploaderDelegate) {
        
        self.delegate = delegate
        
    }
    
    func upload(values: [Int16]) {
        
        let url = NSURL(string: URL_STRING)
        
        var request = NSMutableURLRequest(URL: url!)
        
        var data = data_start
        
        for i in 0..<values.count {
            if i > 0 {
                data += ","
            }
            data += "[" + String(values[i]) + "]"
        }
        
        data += data_end
        
        data += "\"sampleRate\":"
        data += String(44100)
        data += ",\"bitPerSample\":"
        data += String(16)
        data += "}}"
        
        request.HTTPMethod = "POST"
        request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + API_KEY, forHTTPHeaderField: "Authorization")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ response, data, error in
            
            dispatch_async(dispatch_get_main_queue(), {
            
                if data == nil {
                    
                    println(response)
                    
                    println(error)
                    
                    self.delegate.uploadResponse(nil)
                    
                } else {
                    
                    var err : NSError?

                    self.delegate.uploadResponse(NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as? NSDictionary)
                    
                }

            })
        
        })
        
    }
    
}