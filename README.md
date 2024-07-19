

```markdown
# NetForge

NetForge is a lightweight, cross-platform networking abstraction layer for Swift, designed to simplify HTTP networking operations across iOS, macOS, and Linux.

## Features

- Unified API for network requests
- Support for common HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Asynchronous operations using Swift concurrency (`async`/`await`)
- Easy-to-use request and response abstractions
- Built-in support for JSON encoding and decoding
- Query parameter handling
- Customizable headers

## Requirements

- Swift 5.5+
- iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+, or Linux

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```
dependencies: [
    .package(url: "https://github.com/yourusername/NetForge.git", from: "1.0.0")
]
```

Alternatively, you can add NetForge to your Xcode project using the Swift Package Manager by going to `File` > `Add Packages...` and entering the repository URL.

## Usage

### Making a GET Request

```swift
import NetForge

let session = NetForge.Session()

do {
    let request = NetForge.Request(url: URL(string: "https://api.example.com/data")!, method: .get)
    let response = try await session.send(request)
    
    if response.statusCode == 200 {
        if let bodyString = response.bodyAsString {
            print("Response: \(bodyString)")
        }
    } else {
        print("Error: Status code \(response.statusCode)")
    }
} catch {
    print("Error: \(error)")
}
```

### Making a POST Request with JSON Body

```swift
import NetForge

struct User: Codable {
    let name: String
    let email: String
}

let session = NetForge.Session()

do {
    let user = User(name: "John Doe", email: "john@example.com")
    let request = try NetForge.Request(
        url: URL(string: "https://api.example.com/users")!,
        method: .post,
        jsonBody: user
    )
    
    let response = try await session.send(request)
    
    if response.statusCode == 201 {
        let createdUser = try response.decode(User.self)
        print("Created user: \(createdUser.name)")
    } else {
        print("Error: Status code \(response.statusCode)")
    }
} catch {
    print("Error: \(error)")
}
```

### Making a GET Request with Query Parameters

```swift
import NetForge

let session = NetForge.Session()

do {
    let request = NetForge.Request(
        url: URL(string: "https://api.example.com/search")!,
        method: .get,
        queryParameters: ["q": "swift", "limit": "10"]
    )
    
    let response = try await session.send(request)
    
    if response.statusCode == 200 {
        if let results = try? response.decode([String].self) {
            print("Search results: \(results)")
        }
    } else {
        print("Error: Status code \(response.statusCode)")
    }
} catch {
    print("Error: \(error)")
}
```

## Contributing

Contributions to NetForge are welcome! If you have suggestions or find bugs, please submit a Pull Request or open an issue. To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and ensure that they are well-tested.
4. Submit a Pull Request with a clear description of your changes.

## License

NetForge is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
```
# NetForge
