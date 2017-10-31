//
//  FileLoader.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 31/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation

struct FileLoader {
    
    func loadDictionary(fromFileNamed filename: String, extension: String) -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: `extension`),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }
    
    func loadDictionary(fromJsonNamed name: String) -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }
}
