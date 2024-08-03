//
//  NetworkManager.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-03.
//

import Alamofire
import Foundation
import RxSwift

public struct Constants {
    public enum HTTPHeaderField: String {
        case contentType = "Content-Type"
    }
    
    public enum ContentType: String {
        case json = "application/json"
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:3000"
    
    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300
        
        return Session(configuration: configuration)
    }()
        
        private init() {}
    
    func networkTask<ResultType>(endpoint: Endpoint<ResultType>) -> Single<ResultType> {
        return Single.create { [weak self] single in
            guard let self = self else {
                return Disposables.create()
            }
            
            let request = self.urlRequest(endpoint: endpoint)
            
            return dataRequest(request: request).map { data -> ResultType in
                return try JSONDecoder().decode(ResultType.self, from: data)
            }.subscribe(onSuccess: { result in
                single(.success(result))
            }, onFailure: { error in
                single(.failure(error))
            })
        }.observe(on: MainScheduler.instance)
    }
    
    func urlRequest<T>(endpoint: Endpoint<T>) -> DataRequest {
        let routeURL = endpoint.routeString
        let url = baseURL + "/" + routeURL
        
        var request = try! URLRequest(url: url, method: endpoint.method)
        
        if let parameters = endpoint.parameters {
            switch parameters {
            case .object(let parameter):
                if let requestWithObjectParams = try? endpoint.parameterEncoding.encode(request, with: parameter) {
                    request = requestWithObjectParams
                }
            case .data(let data):
                request.httpBody = data
                request.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HTTPHeaderField.contentType.rawValue)
            }
        }
        
        return session.request(request)
    }
    
    func dataRequest(request: DataRequest) -> Single<Data> {
        return Single.create { single in
            let task = request.validate().responseData { response in
                switch response.result {
                case .failure(let error):
                    single(.failure(error))
                case .success(let data):
                    single(.success(data))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
