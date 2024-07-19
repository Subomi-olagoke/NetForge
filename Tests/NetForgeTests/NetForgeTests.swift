import XCTest
@testable import NetForge

final class NetForgeTests: XCTestCase {
    
    func testRequestInitialization() {
        let url = URL(string: "https://api.example.com/data")!
        let request = NetForge.Request(url: url, method: .get)
        
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, .get)
        XCTAssertTrue(request.headers.isEmpty)
        XCTAssertTrue(request.queryParameters.isEmpty)
        XCTAssertNil(request.body)
    }
    
    func testRequestWithQueryParameters() {
        let url = URL(string: "https://api.example.com/search")!
        let queryParams = ["q": "swift", "limit": "10"]
        let request = NetForge.Request(url: url, method: .get, queryParameters: queryParams)
        
        XCTAssertEqual(request.queryParameters, queryParams)
    }
    
    func testRequestWithJSONBody() throws {
        struct TestBody: Codable {
            let name: String
            let age: Int
        }
        
        let url = URL(string: "https://api.example.com/users")!
        let body = TestBody(name: "John", age: 30)
        let request = try NetForge.Request(url: url, method: .post, jsonBody: body)
        
        XCTAssertEqual(request.method, .post)
        XCTAssertNotNil(request.body)
        XCTAssertEqual(request.headers["Content-Type"], "application/json")
    }
    
    func testResponseInitialization() {
        let statusCode = 200
        let headers = ["Content-Type": "application/json"]
        let body = Data("{\"key\":\"value\"}".utf8)
        
        let response = NetForge.Response(statusCode: statusCode, headers: headers, body: body)
        
        XCTAssertEqual(response.statusCode, statusCode)
        XCTAssertEqual(response.headers, headers)
        XCTAssertEqual(response.body, body)
    }
    
    func testResponseDecoding() throws {
        struct TestResponse: Codable, Equatable {
            let key: String
        }
        
        let body = Data("{\"key\":\"value\"}".utf8)
        let response = NetForge.Response(statusCode: 200, headers: [:], body: body)
        
        let decoded = try response.decode(TestResponse.self)
        XCTAssertEqual(decoded, TestResponse(key: "value"))
    }
    
    func testResponseBodyAsString() {
        let body = Data("Hello, World!".utf8)
        let response = NetForge.Response(statusCode: 200, headers: [:], body: body)
        
        XCTAssertEqual(response.bodyAsString, "Hello, World!")
    }
}
