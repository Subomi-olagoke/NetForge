import Foundation

/// NetForge: A cross-platform networking abstraction layer for Swift.
public enum NetForge {
    
    // MARK: - Request
    
    /// Represents an HTTP request.
    public struct Request {
        /// The URL of the request.
        public let url: URL
        
        /// The HTTP method of the request.
        public let method: HTTPMethod
        
        /// The headers of the request.
        public var headers: [String: String]
        
        /// The query parameters of the request.
        public var queryParameters: [String: String]
        
        /// The body of the request.
        public var body: Data?
        
        /// Creates a new Request instance.
        /// - Parameters:
        ///   - url: The URL of the request.
        ///   - method: The HTTP method of the request.
        ///   - headers: The headers of the request. Defaults to an empty dictionary.
        ///   - queryParameters: The query parameters of the request. Defaults to an empty dictionary.
        ///   - body: The body of the request. Defaults to nil.
        public init(url: URL, method: HTTPMethod, headers: [String: String] = [:], queryParameters: [String: String] = [:], body: Data? = nil) {
            self.url = url
            self.method = method
            self.headers = headers
            self.queryParameters = queryParameters
            self.body = body
        }
        
        /// Creates a new Request instance with a JSON body.
        /// - Parameters:
        ///   - url: The URL of the request.
        ///   - method: The HTTP method of the request.
        ///   - headers: The headers of the request. Defaults to an empty dictionary.
        ///   - queryParameters: The query parameters of the request. Defaults to an empty dictionary.
        ///   - jsonBody: The body of the request as a JSON-encodable object.
        public init<T: Encodable>(url: URL, method: HTTPMethod, headers: [String: String] = [:], queryParameters: [String: String] = [:], jsonBody: T) throws {
            let jsonData = try JSONEncoder().encode(jsonBody)
            var headers = headers
            headers["Content-Type"] = "application/json"
            self.init(url: url, method: method, headers: headers, queryParameters: queryParameters, body: jsonData)
        }
    }
    
    // MARK: - Response
    
    /// Represents an HTTP response.
    public struct Response {
        /// The status code of the response.
        public let statusCode: Int
        
        /// The headers of the response.
        public let headers: [String: String]
        
        /// The body of the response.
        public let body: Data
        
        /// Creates a new Response instance.
        /// - Parameters:
        ///   - statusCode: The status code of the response.
        ///   - headers: The headers of the response.
        ///   - body: The body of the response.
        public init(statusCode: Int, headers: [String: String], body: Data) {
            self.statusCode = statusCode
            self.headers = headers
            self.body = body
        }
        
        /// Decodes the response body into a Decodable type.
        /// - Parameter type: The type to decode the response body into.
        /// - Returns: An instance of the specified type.
        /// - Throws: An error if decoding fails.
        public func decode<T: Decodable>(_ type: T.Type) throws -> T {
            return try JSONDecoder().decode(type, from: body)
        }
        
        /// Returns the response body as a String, if possible.
        /// - Returns: The response body as a String, or nil if it can't be converted.
        public var bodyAsString: String? {
            return String(data: body, encoding: .utf8)
        }
    }
    
    // MARK: - HTTPMethod
    
    /// Represents HTTP methods.
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    // MARK: - Session
    
    /// Manages sending network requests.
    public class Session {
        private let urlSession: URLSession
        
        /// Creates a new Session instance.
        /// - Parameter urlSession: The URLSession to use. Defaults to URLSession.shared.
        public init(urlSession: URLSession = .shared) {
            self.urlSession = urlSession
        }
        
        /// Sends a network request.
        /// - Parameter request: The request to send.
        /// - Returns: The response from the server.
        /// - Throws: A `NetForgeError` if the response is invalid, or any network-related error.
        @available(macOS 12.0, *)
        public func send(_ request: Request) async throws -> Response {
            var components = URLComponents(url: request.url, resolvingAgainstBaseURL: true)!
            if !request.queryParameters.isEmpty {
                components.queryItems = request.queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = request.method.rawValue
            urlRequest.allHTTPHeaderFields = request.headers
            urlRequest.httpBody = request.body
            
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw NetForgeError.invalidResponse
            }
            
            return Response(
                statusCode: httpResponse.statusCode,
                headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
                body: data
            )
        }
    }
    
    // MARK: - NetForgeError
    
    /// Represents errors that can occur in NetForge.
    public enum NetForgeError: Error {
        /// Indicates that the server's response was not a valid HTTP response.
        case invalidResponse
        // Add more specific errors as needed
    }
} 
