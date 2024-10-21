class_name CleaningTextureData

var index_count : int = 0

var position_array : Array[Vector2i] = []
var coeff_array : Array[float] = []

static func create(positions : Array[Vector2i], coeffs : Array[float]) -> CleaningTextureData:
    var instance = CleaningTextureData.new()
    instance.position_array = positions
    instance.coeff_array = coeffs
    instance.index_count = len(positions)
    return instance

static func parse_image_data(image : Image) -> CleaningTextureData:
    var image_size = image.get_size()

    var positions : Array[Vector2i] = []
    var coeffs : Array[float] = []

    for i in image_size.x:
        for j in image_size.y:
            positions.append(Vector2i(i - image_size.x / 2, j - image_size.y / 2))
            coeffs.append(image.get_pixel(j, i).r)

    return CleaningTextureData.create(positions, coeffs)