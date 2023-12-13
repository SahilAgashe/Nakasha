//
//  String+Extensions.swift
//  MyApp
//
//  Created by SAHIL AMRUT AGASHE on 14/12/23.
//

import Foundation

extension String {
    
    var formatPhoneForCall: String {
        self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            
    }
}
