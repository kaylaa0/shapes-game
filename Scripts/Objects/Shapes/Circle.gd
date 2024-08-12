extends MyMotileShape

func _ready():
	canMove = true
	super()
	pass

func specialAbility():
	pass


func _physics_process(_delta):
	if get_physics_material_override() != null:
		if isFocused:
			get_physics_material_override().set_bounce(0.2)
		else:
			if get_physics_material_override().get_bounce() > 0:
				get_physics_material_override().set_bounce(0)

#func _process(delta):
#	pass
