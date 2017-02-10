import Foundation
import Alamofire
import RealmSwift


@objc enum ServiceError: Int {
    case NoCachedHistoryFound
}


@objc class TimeTableEntity: NSObject {
    
    let id: Int
    let providerLogo: URL?
    let priceInEuros: NSDecimalNumber // Could be String or Number in JSON
    let departureTime: String
    let arrivalTime: String
    let numberOfStops: Int
    
    enum Keys {
        static let id               = "id"
        static let providerLogo     = "provider_logo"
        static let priceInEuros     = "price_in_euros"
        static let departureTime    = "departure_time"
        static let arrivalTime      = "arrival_time"
        static let numberOfStops    = "number_of_stops"
    }
    
    override init() {
        id = 0
        providerLogo = nil
        priceInEuros = NSDecimalNumber(string: "0")
        departureTime = ""
        arrivalTime = ""
        numberOfStops = 0
    }
    
}


typealias GetFlightTimeTableCompletion = ([TimeTableEntity]?, NSError?) -> Void

@objc protocol TimeTableService {
    /// Get flight time table
    //func getFlightTimeTable(completion: (TimeTableEntity?, ServiceError?) -> Void)
    func getFlightTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void)
}

protocol TimeTableDataProvider {
    /// Get flight time table
    func getFlightTimeTable(completion: @escaping GetFlightTimeTableCompletion)
}

class DefaultTimeTableService: TimeTableService {
    
    let dataProvider: TimeTableDataProvider
    
    init(dataProvider: TimeTableDataProvider) {
        self.dataProvider = dataProvider
    }
    
    /// Get flight time table
    internal func getFlightTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void) {
        dataProvider.getFlightTimeTable(completion: completion)
    }
}

class DefaultTimeTableDataProvider: TimeTableDataProvider {
    
    func getFlightTimeTable(completion: @escaping GetFlightTimeTableCompletion) {
        let urlString = "https://api.myjson.com/bins/w60i"
        
        Alamofire.request(urlString).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value as? [Any]//,
//                    let entity = BPICurrentPriceEntity(JSON: json)
                {
                    print(json)
//                    completion(.success(entity))
                }
            case .failure(let error):
                completion(nil, error as NSError)
            }
        }
    }

}

@objc class Services: NSObject {
    static let _defaultTimeTableDataProvider: TimeTableDataProvider = DefaultTimeTableDataProvider()
    static let _defaultTimeTableService: TimeTableService = DefaultTimeTableService(dataProvider: _defaultTimeTableDataProvider)
    
    @objc class func defaultTimeTableService() -> TimeTableService {
        return _defaultTimeTableService
    }
}
