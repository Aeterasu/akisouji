class_name LeafCleaningQuery

var query_data : PhysicsDirectSpaceState3D = null

static func create(data : PhysicsDirectSpaceState3D) -> LeafCleaningQuery:
    var instance = LeafCleaningQuery.new()
    instance.query_data = data
    return instance