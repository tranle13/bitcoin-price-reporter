import Foundation

protocol CoinManagerDelegate {
	func didGetCurrencyRate(rate: Double)
	func didFailWithError(_ error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "D7FB2703-DA3B-4725-B431-10A5FF5F04A0"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
	var delegate: CoinManagerDelegate?

	func getCoinPrice(for currency: String) {
		let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
		performRequest(with: urlString)
	}
	
	func performRequest(with urlString: String) {
		if let url = URL(string: urlString) {
			let urlSession = URLSession(configuration: .default)
			let task = urlSession.dataTask(with: url) { data, response, error in
				if (error != nil) {
					self.delegate?.didFailWithError(error!)
				}
				if let safeData = data {
					if let rate = parseJSON(safeData) {
						self.delegate?.didGetCurrencyRate(rate: rate)
					}
				}
			}
			task.resume()
		}
	}
	
	func parseJSON(_ coinData: Data) -> Double? {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode(CoinData.self, from: coinData)
			return decodedData.rate
		} catch {
			delegate?.didFailWithError(error)
			return nil
		}
	}
}
