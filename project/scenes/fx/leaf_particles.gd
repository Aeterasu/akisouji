extends GPUParticles3D

func _ready():
	finished.connect(_on_finished)

func _on_finished():
	self.queue_free()