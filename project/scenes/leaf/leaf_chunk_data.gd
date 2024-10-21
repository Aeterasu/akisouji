class_name LeafChunkData

var viewport_position : Vector2i = Vector2i()
var indexes : Array[int] = []
var index_count : int = 0

var last_clean_index = 0

static func create(position : Vector2i) -> LeafChunkData:
    var instance = LeafChunkData.new()
    instance.viewport_position = position
    return instance