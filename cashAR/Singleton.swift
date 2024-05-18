//
//  File.swift
//  AR_prueba
//
//  Created by Ivanovicx Nuñez on 15/05/24.
//

import Foundation

let API_KEY : String = "4f1460a289-d991886ba2-sdjupz"
let url = URL(string: "https://api.fastforex.io/fetch-all")!

var total_ : Double = 0.0
var currency_origin : String = "MXN"
var currency_detiny : String = "USD"

struct ExchangeResponse: Codable {
    let base: String
    let amount: Double
    let result: [String: Double]
    let ms: Int
}
