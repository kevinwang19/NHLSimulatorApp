//
//  Endpoint.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-03.
//

import Alamofire
import Foundation

public enum ParameterType {
    case object(Parameters)
    case data(Data)
    
    var object: Parameters? {
        if case let .object(parameter) = self {
            return parameter
        }
        return nil
    }
    
    var data: Data? {
        if case let .data(data) = self {
            return data
        }
        return nil
    }
}

public protocol EndpointInfo {
    var route: String { get }
}

struct Endpoint<ResultType> where ResultType: Decodable {
    let requestInfo: EndpointInfo?
    var method: HTTPMethod
    var parameters: ParameterType?
    let parameterEncoding: ParameterEncoding
    
    var routeString: String {
        return self.requestInfo?.route ?? ""
    }
    
    public init(method: HTTPMethod, info: EndpointInfo?, parameters: ParameterType?, resultType: ResultType.Type) {
        if let info = info {
            self.requestInfo = info
        }
        else {
            requestInfo = nil
        }
        
        self.method = method
        self.parameters = parameters
        parameterEncoding = (method == .get) ? URLEncoding.default : JSONEncoding.default
    }
}
