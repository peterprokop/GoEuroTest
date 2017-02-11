import Foundation
import Alamofire
import RealmSwift

typealias GetFlightTimeTableCompletion = ([TimeTableEntity]?, NSError?) -> Void

@objc protocol TimeTableService {
    /// Get flight time table
    func getFlightTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void)
    
    /// Get train time table
    func getTrainTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void)
    
    /// Get bus time table
    func getBusTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void)
}

protocol TimeTableDataProvider {
    /// Get flight time table
    func getFlightTimeTable(completion: @escaping GetFlightTimeTableCompletion)
    
    /// Get train time table
    func getTrainTimeTable(completion: @escaping GetFlightTimeTableCompletion)
    
    /// Get bus time table
    func getBusTimeTable(completion: @escaping GetFlightTimeTableCompletion)
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
    
    /// Get train time table
    internal func getTrainTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void) {
        dataProvider.getTrainTimeTable(completion: completion)
    }
    
    /// Get bus time table
    internal func getBusTimeTable(completion: @escaping ([TimeTableEntity]?, NSError?) -> Void) {
        dataProvider.getBusTimeTable(completion: completion)
    }
}

class DefaultTimeTableDataProvider: TimeTableDataProvider {
    
    func getFlightTimeTable(completion: @escaping GetFlightTimeTableCompletion) {
        let urlString = "https://api.myjson.com/bins/w60i"
        getTimeTable(urlString: urlString, completion: completion)
    }
    
    func getTrainTimeTable(completion: @escaping GetFlightTimeTableCompletion) {
        let urlString = "https://api.myjson.com/bins/3zmcy"
        getTimeTable(urlString: urlString, completion: completion)
    }
    
    func getBusTimeTable(completion: @escaping GetFlightTimeTableCompletion) {
        let urlString = "https://api.myjson.com/bins/37yzm"
        getTimeTable(urlString: urlString, completion: completion)
    }

    fileprivate func getTimeTable(urlString: String, completion: @escaping GetFlightTimeTableCompletion) {
        Alamofire.request(urlString).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let timeTable: [TimeTableEntity] = try? response.result.value.array() {
                    completion(timeTable, nil)
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Server response doesn't match data model"]
                    let error = NSError(domain: "com.goeurotest.error",
                                        code: 1001,
                                        userInfo: userInfo)
                    completion(nil, error)
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
