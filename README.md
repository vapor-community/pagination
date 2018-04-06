# Vapor Pagination

Pagination is based off of the Fluent 2 pagination system.

## Getting Started
Add this to your Package.swift file
```swift
.package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.0-rc")
```

Conform your model to `Paginatable`

```swift
extension MyModel: Paginatable { }
```

Once you have done that, it's as simple as returning your query in paginated format.
```swift
func listAllSchools(_ req: Request) throws -> Future<Paginated<MyModel>> {
    return try MyModel.query(on: req).paginate(for: req)
}
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

## Known issues
There appears to be an issue with Fluent's `GROUP BY` and `ORDER BY`. You can keep updated with the status of this issue here https://github.com/vapor/fluent/issues/438
For the time being. Sorting has been disabled.

## Todo
- [ ] Re-enable the sorting when it's fixed in Fluent
- [ ] Implement tests
