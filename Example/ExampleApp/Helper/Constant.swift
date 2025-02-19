//
//  Constant.swift
//  ExampleApp
//
//  Created by Parth on 25/01/25.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
           let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
           let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
           return emailPredicate.evaluate(with: self)
       }
   
}
