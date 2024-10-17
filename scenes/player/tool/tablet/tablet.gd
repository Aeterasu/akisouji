class_name Tablet extends PlayerTool

@export var mesh : MeshInstance3D = null

var material : StandardMaterial3D = null

func _ready():
	super()
	material = mesh.get_surface_override_material(1)

func _physics_process(delta):
	super(delta)

func _process(delta):
	var tablet_screen = TabletScreen.instance

	if (tablet_screen):
		var texture = tablet_screen.get_texture()
		material.albedo_texture = texture
		material.emission_texture = texture