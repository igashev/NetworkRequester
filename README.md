# NetworkRequester

NetworkRequester is an HTTP Combine-only networking library.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+
- Xcode 12+
- Swift 5.3+

## Installation

### Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

NetworkRequester supports only SPM and adding it as a dependency is done just by including the URL into the `dependencies` value of your `Package.swift`.
```swift
dependencies: [
    .package(
        url: "https://github.com/igashev/NetworkRequester.git",
        .upToNextMajor(from: "1.2.0")
    )
]
```
Or by using the integrated tool of Xcode.

## Usage

### Building requests

NetworkRequester provides a very easy way to build a request using `URLRequestBuilder`.
```swift
// Creating a builder
let requestBuilder = URLRequestBuilder(
    environment: Environment.production,
    endpoint: UsersEndpoint.users,
    httpMethod: .get,
    httpHeaders: [
        .json, 
        .authorization(bearerToken: "secretBearerToken")
    ],
    httpBody: nil,
    queryParameters: nil
)
```

### Calling requests

There are two options with which to make the actual network request.

The first option is using plain `URLRequest`.
```swift
struct User: Decodable {
    let name: String
}

struct BackendError: DecodableError {
    let errorCode: Int
    let localizedError: String
}

let url = URL(string: "https://amazingapi.com/v1/users")!
let urlRequest = URLRequest(url: url)

let caller = AsyncCaller(decoder: JSONDecoder())
let user: User = try await caller.call(
    using: urlRequest, 
    errorType: BackendError.self
)
```

The second option is using `URLRequestBuilder`.
```swift
struct User: Decodable {
    let name: String
}

struct BackendError: DecodableError {
    let errorCode: Int
    let localizedError: String
}

let requestBuilder = URLRequestBuilder(
    environment: "https://amazingapi.com",
    endpoint: "v1/users",
    httpMethod: .get,
    httpHeaders: [
        .json, 
        .authorization(bearerToken: "secretBearerToken")
    ],
    httpBody: nil,
    queryParameters: nil
)

let caller = AsyncCaller(decoder: JSONDecoder())
let user: User = try await caller.call(
    using: requestBuilder, 
    errorType: BackendError.self
)
```
Take into account that when a response data is expected, a type that conforms to `Encodable` should be specified as `Output`. Otherwise `Void`.
