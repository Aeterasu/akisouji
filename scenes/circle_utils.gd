class_name CircleUtils

static func get_circle_vector_array(origin : Vector2i, r: int) -> Array[Vector2i]:
    var result : Array[Vector2i] = []
    result.append(origin)

    if (r < 0):
        r = 0

    var x1 : float = 0.0
    var y1 : float = 0.0

    var minAngle : float = acos(1.0 - 1.0 / r)

    var angle : float = 0.0

    while (angle <= 360.0):
        angle += minAngle

        x1 = r * cos(angle)
        y1 = r * sin(angle)

        var pixel_origin = Vector2i(origin.x + round(x1), origin.y + round(y1))

        if (!result.has(pixel_origin)):
            result.append(pixel_origin)

    return result