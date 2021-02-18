# NetworkRequester

NetworkRequester is an HTTP Combine-only networking library.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Conclusion](#conclusion)

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
    .package(url: "https://github.com/igashev/NetworkRequester.git", .upToNextMajor(from: "1.2.0"))
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
    httpHeaders: [.json, .authorization(bearerToken: "secretBearerToken")],
    httpBody: nil,
    queryParameters: nil
)

// Building a URLRequest
do {
    let urlRequest = try requestBuilder.build()
} catch {
    // Possible errors that could be thrown here are NetworkingError.buildingURL and NetworkingError.encoding(error:)
}
```

### Calling requests

There are two options with which to make the actual network request.

The first option is using plain `URLRequest`.
```swift
let url = URL(string: "https://example.get.request.com")!
let urlRequest = URLRequest(url: url)

let caller = URLRequestCaller(decoder: JSONDecoder())
let examplePublisher: AnyPublisher<Void, NetworkingError> = caller.call(using: urlRequest) // Expects no response data as Void is specified as Output
```

The second option is using `URLRequestBuilder`.
```swift
let requestBuilder = URLRequestBuilder(
    environment: Environment.production,
    endpoint: UsersEndpoint.users,
    httpMethod: .get,
    httpHeaders: [.json, .authorization(bearerToken: "secretBearerToken")],
    httpBody: nil,
    queryParameters: nil
)

let caller = URLRequestCaller(decoder: JSONDecoder())
let examplePublisher: AnyPublisher<User, NetworkingError> = caller.call(using: requestBuilder) // Expects response data as User is specified as Output
```
Take into account that when a response data is expected, a type that conforms to `Encodable` should be specified as `Output`. Otherwise `Void`.

## Conclusion

NetworkRequester is still very young. Improvements and new functionalities will be coming. Pull requests and suggestions are very welcomed.