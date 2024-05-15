//
//  ExchangeController.swift
//  AR_prueba
//
//  Created by Ivanovicx Nuñez on 15/05/24.
//

import UIKit

class ExchangeController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var labelTotal: UILabel!
    
    @IBOutlet weak var labelTotalExchanged: UILabel!
    
    
    let currencies : [String] = ["AED","AFN","ALL","AMD","ANG","AOA","ARS","AUD","AWG","AZN","BAM","BBD","BDT","BGN","BHD","BIF","BMD","BND","BOB","BRL","BSD","BTN","BWP","BZD","CAD","CDF","CHF","CLF","CLP","CNH","CNY","COP","CUP","CVE","CZK","DJF","DKK","DOP","DZD","EGP","ERN","ETB","EUR","FJD","FKP","GBP","GEL","GHS","GIP","GMD","GNF","GTQ","GYD","HKD","HNL","HRK","HTG","HUF","IDR","ILS","INR","IQD","IRR","ISK","JMD","JOD","JPY","KES","KGS","KHR","KMF","KPW","KRW","KWD","KYD","KZT","LAK","LBP","LKR","LRD","LSL","LYD","MAD","MDL","MGA","MKD","MMK","MNT","MOP","MRU","MUR","MVR","MWK","MXN","MYR","MZN","NAD","NGN","NOK","NPR","NZD","OMR","PAB","PEN","PGK","PHP","PKR","PLN","PYG","QAR","RON","RSD","RUB","RWF","SAR","SCR","SDG","SEK","SGD","SHP","SLL","SOS","SRD","SYP","SZL","THB","TJS","TMT","TND","TOP","TRY","TTD","TWD","TZS","UAH","UGX","USD","UYU","UZS","VND","VUV","WST","XAF","XCD","XDR","XOF","XPF","YER","ZAR","ZMW"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTotal.text = String( total_ )

    }
    
//    func exchange (toCurrency : String) async {
//        
//        let url = URL(string: "https://api.fastforex.io/convert")!
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
//        let queryItems: [URLQueryItem] = [
//          URLQueryItem(name: "api_key", value: "4f1460a289-d991886ba2-sdjupz"),
//        ]
//        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
//
//        var request = URLRequest(url: components.url!)
//        request.httpMethod = "GET"
//        request.timeoutInterval = 10
//        request.allHTTPHeaderFields = ["accept": "application/json"]
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(for: request)
//            print(String(decoding: data, as: UTF8.self))
//        } catch {
//            print("Error fetching exchange rate: \(error)")
//        }
//
//        let (data, _) = try await URLSession.shared.data(for: request)
//        print(String(decoding: data, as: UTF8.self))
//
//    }
    
    func exchange(toCurrency: String) async {
        let url = URL(string: "https://api.fastforex.io/convert")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: "4f1460a289-d991886ba2-sdjupz"),
            URLQueryItem(name: "to", value: toCurrency) // Agrega la moneda de destino a los parámetros de consulta
        ]
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Decodificar el JSON
            let decoder = JSONDecoder()
            let exchangeResponse = try decoder.decode(ExchangeResponse.self, from: data)
            
            // Acceder a los atributos
            print("Base: \(exchangeResponse.base)")
            print("Amount: \(exchangeResponse.amount)")
            
            // Acceder al resultado para la moneda específica
            if let rate = exchangeResponse.result[toCurrency] {
                print("\(toCurrency): \(rate)")
                labelTotalExchanged.text = String( "\(total_)  \(currency_origin) = \(rate) \(currency_detiny)")
            } else {
                print("Rate for \(toCurrency) not found")
            }
            
            print("Milliseconds: \(exchangeResponse.ms)")
            
        } catch {
            print("Error fetching exchange rate: \(error)")
        }
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    private func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) async {
        currency_detiny = String(currencies[row].prefix(3))
        await exchange(toCurrency: currencies[row])
    }

}
