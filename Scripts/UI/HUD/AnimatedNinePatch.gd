extends Control

@export var direction:int # 0 horizontal 1 vertical # (int, "horizontal", "vertical")
@export var isSummonButton: bool
var animationName:String
var isReadyForced:bool = false
var bar:BoxContainer
var buttonStyleHover = StyleBoxFlat.new()
var buttonStylePressed = StyleBoxFlat.new()
var buttonStyleFocus = StyleBoxEmpty.new()
var buttonStyleDisable = StyleBoxFlat.new()
var buttonStyleNormal = StyleBoxFlat.new()

var directShapesIn:Array

@onready var animationPlayer = get_node("AnimationPlayer")
var summonSelectButtonScript = load("res://Scripts/UI/HUD/SummonButtonSelectButton.gd")

var isMouseHovered:bool = false
var mouseHoveredChild:bool = false
signal mouseHovered
# warning-ignore:unused_signal
signal directionSet
var ignoreInput:bool = false
var parentANP = null

# Called when the node enters the scene tree for the first time.
func _ready():
	animationName = str(self.get_name())+" "+str(self.get_instance_id())
	if !isReadyForced:
		if direction == 0:
			bar = HBoxContainer.new()
# warning-ignore:return_value_discarded
			GameManager.get_player().connect("sbUpdateNeeded",Callable(self,"update_main_content"))
		elif direction == 1:
			bar = VBoxContainer.new()
			bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		else:
			print_debug("Invalid direction at _ready for Animated Patch.")
			
		generate_style_boxes()
		bar.set_custom_minimum_size(Vector2(120,120))
		
		if isSummonButton:
			init_main_node()
		
		get_node("NinePatchRect").add_child(bar)
		var hoverDetect = Control.new()
		hoverDetect.set_custom_minimum_size(Vector2(120,120))
		hoverDetect.set_name("HoverDetect")
		hoverDetect.set_anchors_and_offsets_preset(PRESET_FULL_RECT) # Eskiden preset_wide dı şimdi yok
		hoverDetect.set_mouse_filter(MOUSE_FILTER_IGNORE)
# warning-ignore:return_value_discarded
		connect("mouseHovered",Callable(self,"mouse_hovered"))
		get_node("NinePatchRect").add_child(hoverDetect)
	generate_animation()

func force_ready():
	animationName = str(self.get_name())+" "+str(self.get_instance_id())
	isSummonButton = false
	if direction == 0:
		bar = HBoxContainer.new()
# warning-ignore:return_value_discarded
		GameManager.get_player().connect("sbUpdateNeeded",Callable(self,"update_main_content"))
	elif direction == 1:
		bar = VBoxContainer.new()
		bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		#bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		#bar.set_v_grow_direction(GROW_DIRECTION_BEGIN)
	else:
		print_debug("Invalid direction at force_ready for Animated Patch.")
		
	generate_style_boxes()
	bar.set_custom_minimum_size(Vector2(120,120))
	
	if isSummonButton:
		init_main_node()
		
	get_node("NinePatchRect").add_child(bar)
	var hoverDetect = Control.new()
	hoverDetect.set_custom_minimum_size(Vector2(120,120))
	hoverDetect.set_name("HoverDetect")
	hoverDetect.set_anchors_and_offsets_preset(PRESET_FULL_RECT) # Eskiden preset_wide dı şimdi yok
	hoverDetect.set_mouse_filter(MOUSE_FILTER_IGNORE)
# warning-ignore:return_value_discarded
	connect("mouseHovered",Callable(self,"mouse_hovered"))
	get_node("NinePatchRect").add_child(hoverDetect)
	isReadyForced = true


func init_dict(dict:Dictionary)->void:
	var controlSet:bool = false
	var control = Control.new()
	var patch = load("res://Scenes/UI/HUD/AnimatedNinePatch.tscn").instantiate()
	patch.parentANP = self
	for key in dict.keys():
		var shape = dict[key]
		if !controlSet:
			control.set_custom_minimum_size(Vector2(120,120))
			control.set_name(shape.get_name())
			control.set_mouse_filter(MOUSE_FILTER_IGNORE)
			patch.set_direction("Vertical")
			patch.force_ready()
			patch.init_shape(shape)
			patch.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			#patch.set_position(Vector2(0,0))
			control.add_child(patch)
			bar.add_child(control)
			controlSet = true
		else:
			patch.init_shape(shape)

func init_shape(shape:MyShape)->void:
	var control = Control.new()
	control.set_custom_minimum_size(Vector2(120,120))
	control.set_name(shape.get_name())
	control.set_mouse_filter(MOUSE_FILTER_IGNORE)
	var button = create_select_button(shape.get_name())
	control.add_child(button)
	bar.add_child(control)
	if self.direction == 1:
		bar.move_child(control, 0)
	directShapesIn.append(shape.get_name())

func add_to_bar(shapeName:String, shape:MyShape)->void:
	for child in bar.get_children():
		if child.get_name() == shapeName:
			bar.get_node(shapeName).add_child(shape)
			bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
			return
		elif child.has_node("AnimatedNinePatch"):
			if child.get_node("AnimatedNinePatch").has_directShape(shapeName):
				child.get_node("AnimatedNinePatch").add_to_bar(shapeName, shape)
				return
	print_debug("Can not find place in bar to add shape: "+shapeName)
	

func update_main_content():
	if !(bar.get_node("Main").get_child_count() == 1):
		bar.get_node("Main").get_child(1).queue_free()
#	print(GameManager.get_player().get_selected_spawn())
#	print(GameManager.get_player().get_next_spawns())
	var dummyShape:MyShape = GameManager.get_player().get_next_spawns()[GameManager.get_player().get_selected_spawn()].duplicate()
	dummyShape.set_freeze_enabled(true)  # eskisi dummyShape.set_mode(1)
	dummyShape.to_simpleton()
	dummyShape.set_position(Vector2(60,60))
	dummyShape.set_scale(Vector2(1.2,1.2))
	bar.get_node("Main").add_child(dummyShape)

func update_contents():
	if isSummonButton:
		update_main_content()
	for shapeName in GameManager.get_player().get_next_spawns().keys():
		clear_contents(shapeName)
		var dummyShape:MyShape = GameManager.get_player().get_next_spawns()[shapeName].duplicate()
		dummyShape.set_freeze_enabled(true)  # eskisi dummyShape.set_mode(1)
		dummyShape.to_simpleton()
		dummyShape.set_position(Vector2(60,60))
		dummyShape.set_scale(Vector2(1.2,1.2))
		add_to_bar(shapeName, dummyShape)
		

func clear_contents(shapeName:String)->void:
	for child in bar.get_children():
		if child.has_node(shapeName+" button"):
			for child2 in child.get_children():
				if child2.get_name() != shapeName+" button":
					child2.queue_free()
			return
		elif child.has_node("AnimatedNinePatch"):
			if child.get_node("AnimatedNinePatch").has_directShape(shapeName):
				child.get_node("AnimatedNinePatch").clear_contents(shapeName)
				return
	print_debug("Can not find shape to clear in clear contents: "+shapeName)

func create_select_button(shapeName:String)->Button:
	var button = set_style_boxes(Button.new())
	button.set_custom_minimum_size(Vector2(100,100))
	button.set_position(Vector2(10,10))
	button.set_name(shapeName+" button")
	button.set_mouse_filter(MOUSE_FILTER_PASS)
	button.set_focus_mode(0)
	#button.set_flat(false)
	button.set_script(summonSelectButtonScript)
	if self.direction == 0:
		if isSummonButton:
			button.connect("updateNeeded",Callable(self,"update_main_content"))
	elif self.direction == 1:
		button.connect("updateNeeded",Callable(parentANP,"update_main_content"))
	button.request_ready()
	return button

func init_main_node():
	var control = Control.new()
	control.set_custom_minimum_size(Vector2(120,120))
	control.set_name("Main")
	control.set_mouse_filter(MOUSE_FILTER_IGNORE)
	var button = set_style_boxes(Button.new())
	button.set_custom_minimum_size(Vector2(100,100))
	button.set_position(Vector2(10,10))
	button.set_name("Main button")
	button.connect("pressed",Callable(self,"_main_button_pressed"))
	button.set_mouse_filter(MOUSE_FILTER_PASS)
	#button.set_flat(false)
	control.add_child(button)
	bar.add_child(control)

func _main_button_pressed()->void:
	GameManager.get_player().spawn_object(GameManager.get_player().get_selected_spawn())
	

func set_style_boxes(button:Button)->Button:
	button.add_theme_stylebox_override('hover', buttonStyleHover)
	button.add_theme_stylebox_override('pressed', buttonStylePressed)
	button.add_theme_stylebox_override('focus', buttonStyleFocus)
	button.add_theme_stylebox_override('disable', buttonStyleDisable)
	button.add_theme_stylebox_override('normal', buttonStyleNormal)
	return button

func generate_style_boxes():
	buttonStyleHover.set_bg_color(Color("#f483af"))
	buttonStyleHover.set_corner_radius_all(100)
	buttonStylePressed.set_bg_color(Color("#ef649a"))
	buttonStylePressed.set_corner_radius_all(100)
	buttonStyleDisable.set_bg_color(Color("#00ef649a"))
	buttonStyleDisable.set_corner_radius_all(100)
	buttonStyleNormal.set_bg_color(Color("#ff73aa"))
	buttonStyleNormal.set_corner_radius_all(100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_animation():
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	#print(track_index)
	if self.direction == 0:
		animation.track_set_path(track_index, ":size")
		animation.track_insert_key(track_index, 0.0, Vector2(120, 120))
		animation.set_length(0.5)
	elif self.direction == 1:
		animation.set_length(0.25)
		animation.track_set_path(track_index, "NinePatchRect:offset_top")
		animation.track_insert_key(track_index, 0.0, 0)
	
	var track_index2 = animation.add_track(Animation.TYPE_VALUE)
	animation.value_track_set_update_mode(track_index2, Animation.UPDATE_DISCRETE) # UPDATE_TRIGGER dı eskiden
	animation.track_set_path(track_index2, "NinePatchRect:clip_contents")
	var animationLibrary
	if !animationPlayer.has_animation_library(self.get_name()):
		animationLibrary = AnimationLibrary.new()
		animationLibrary.add_animation(animationName, animation)
		animationPlayer.add_animation_library(self.get_name(), animationLibrary)
	else:
		animationPlayer.get_animation_library(self.get_name()).add_animation(animationName, animation)

func mouse_hovered():
	self.isMouseHovered = true
	if parentANP != null:
		parentANP.mouseHoveredChild = true
#	print(bar.size)
#	print(bar)
#	print(offset_top)
	#print(1)
	if animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_get_key_count(0) == 1:
		if self.direction == 0:
			animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_insert_key(0, 0.3, bar.size)
			animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_insert_key(1, 0.3, 1)
			animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_insert_key(1, 0.31, 0)
		elif self.direction == 1:
			#animationPlayer.get_animation(animationName).track_insert_key(0, 0.15, bar.size)
			animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_insert_key(0, 0.15, -bar.size.y+120)
			animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_insert_key(1, 0.15, 1)
			animationPlayer.get_animation("AnimatedNinePatch/"+animationName).track_insert_key(1, 0.16, 0)
	animationPlayer.play("AnimatedNinePatch/"+animationName)

func _on_AnimatedNinePatch_resized():
	get_node("NinePatchRect").set_size(Vector2(self.get_size().x, self.get_size().y))

func ignore_input():
	self.ignoreInput = true
	for child in bar.get_children():
		if child.has_node("AnimatedNinePatch"):
			child.get_node("AnimatedNinePatch").ignore_input()

func continue_input():
	self.ignoreInput = false
	for child in bar.get_children():
		if child.has_node("AnimatedNinePatch"):
			child.get_node("AnimatedNinePatch").continue_input()

func _physics_process(_delta):
	if (self.get_node("NinePatchRect/HoverDetect").get_rect().has_point(get_viewport().get_mouse_position()-self.get_node("NinePatchRect/HoverDetect").get_global_position())) and not ignoreInput:
		if !isMouseHovered:
			emit_signal("mouseHovered")
	else:
		if mouseHoveredChild:
			pass
		elif isMouseHovered:
			animationPlayer.play_backwards("AnimatedNinePatch/"+animationName)
			self.isMouseHovered = false
			if parentANP != null:
				parentANP.mouseHoveredChild = false

func has_directShape(shapeName:String)->bool:
	return directShapesIn.has(shapeName)

func set_direction(direct:String)->void:
	if direct == "Horizontal":
		direction = 0
	elif direct == "Vertical":
		direction = 1
	else:
		direction = 0
		print_debug("Invalid direction for an Animated Patch")
