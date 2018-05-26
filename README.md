# Vapor Pagination

Pagination is based off of the Fluent 2 pagination system.

## Getting Started
Add this to your Package.swift file
```swift
.package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.0")
```

Conform your model to `Paginatable`

```swift
extension MyModel: Paginatable { }
```

Once you have done that, it's as simple as returning your query in paginated format.
```swift
func test(_ req: Request) throws -> Future<Paginated<MyModel>> {
    return try MyModel.query(on: req).paginate(for: req)
}
```
Even return items off of the query builder
```swift
func test(_ req: Request) throws -> Future<Paginated<MyModel>> {
    return try MyModel.query(on: req).filter(\MyModel.name == "Test").paginate(for: req)
}
```

Making a request with the parameters is easy is appending `?page=` and/or `?per=`
```curl
curl "http://localhost:8080/api/v1/models?page=1&per=10"
```

A response looks like this
```json
{
  "data": [{
    "updatedAt": "2018-03-07T00:00:00Z",
    "createdAt": "2018-03-07T00:00:00Z",
    "name": "My Test Model"
  }],
  "page": {
    "position": {
      "current": 1,
      "max": 1
    },
    "data": {
      "per": 10,
      "total": 2
    }
  }
}
```
