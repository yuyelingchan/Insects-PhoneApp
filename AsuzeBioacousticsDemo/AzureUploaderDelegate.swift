//
//  AzureUploaderDelegate.swift
//  AzureBioacousticsDemo
//
//  Created by acr on 21/07/2015.
//  Copyright (c) 2015 University of Southampton. All rights reserved.
//

import Foundation

protocol AzureUploaderDelegate {
    
    func uploadResponse(results: NSDictionary?)

}