class_name LeafInstanceData

var viewport_position : Vector2i = Vector2i()
var indexes : Array[int] = []
var index_count : int = 0

static func create(position : Vector2i) -> LeafInstanceData:
    var instance = LeafInstanceData.new()
    instance.viewport_position = position
    return instance