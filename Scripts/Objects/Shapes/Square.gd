extends MyShape


var filling = 1
var specialSpamTimer = Timer.new()
@export var printer = false


func _ready():
	inertiaMultiplier = 40
	specialSpamTimer.set_one_shot(true)
	specialSpamTimer.set_wait_time(0.01)
#	specialSpamTimer.connect("timeout",Callable(self,"special_spam_timeout"))
	
	add_child(specialSpamTimer)
	super()
	pass

func specialAbility():
	if specialSpamTimer.is_stopped():
		for N in get_children():
			if N.has_method("set_scale"):
				filling += (log(filling+1)/filling+1)/1000
				N.set_scale(Vector2(sqrt(filling), sqrt(filling)))
		customInertia = initInertia * filling
		customMass = initMass*sqrt(filling)
		set_mass(initMass*filling)
		specialSpamTimer.start()



func _physics_process(_delta):
	if isActive and printer:
		if get_constant_force().x != 0:
			print(get_linear_velocity())
		if get_constant_force().y != 0:
			print(get_linear_velocity())
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
