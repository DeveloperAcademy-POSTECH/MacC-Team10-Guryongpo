//
//  PhraseData.swift
//  SoccerBeat
//
//  Created by Gucci on 10/31/23.
//

import Foundation

struct PhraseResponse: Decodable {
    let phrase: [Phrase]
}
struct Phrase : Decodable {
    let name: String
    let saying: String
    
    static var randomElement: Self {
        let response: PhraseResponse = Bundle.main.decode(by: "Phrase.json")
        return response.phrase.randomElement() ?? .init(name: "Zlatan Ibrahimovic", saying: "I don’t believe in luck, I only believe in hard work")
    }
}
