//
//  PhraseData.swift
//  SoccerBeat
//
//  Created by Gucci on 10/31/23.
//

import Foundation

struct ResponseData: Decodable {
    var phrase: [Phrase]
}
struct Phrase : Decodable {
    var name: String
    var saying: String
}

func loadJson(filename fileName: String) -> [Phrase]? {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(ResponseData.self, from: data)
            return jsonData.phrase
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}
