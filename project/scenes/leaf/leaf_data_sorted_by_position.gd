class_name LeafInstanceData

var instance_position : Vector2 = Vector2()
var instance_index : int = 0

static func create(position : Vector2, index : int) -> LeafInstanceData:
    var instance = LeafInstanceData.new()
    instance.instance_position = position
    instance.instance_index = index
    return instance