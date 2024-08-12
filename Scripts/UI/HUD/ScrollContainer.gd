extends ScrollContainer

@onready var bar:GridContainer = get_node("GridContainer")
var buttonStyleHover = StyleBoxFlat.new()
var buttonStylePressed = StyleBoxFlat.new()
var buttonStyleFocus = StyleBoxEmpty.new()
var buttonStyleDisable = StyleBoxFlat.new()
var buttonStyleNormal = StyleBoxFlat.new()

var craftableButtonStyleHover = StyleBoxFlat.new()
var craftableButtonStylePressed = StyleBoxFlat.new()
var craftableButtonStyleFocus = StyleBoxEmpty.new()
var craftableButtonStyleDisable = StyleBoxFlat.new()
var craftableButtonStyleNormal = StyleBoxFlat.new()

var craftMenuButtonScript = load("res://Scripts/UI/HUD/CraftMenuSelectButton.gd")

@onready var mainButton:Button = get_parent().get_parent().get_parent().get_parent().get_node("MarginContainer/Button")
signal updateMainSignal(mode)
signal selectUpdateSignal(name, mode)

var mouseIsOverButton = false

func _ready():
	self.get_v_scroll_bar().set_step(100)
	
# warning-ignore:return_value_discarded
	connect("mouse_entered",Callable(self,"_on_mouse_entered"))
# warning-ignore:return_value_discarded
	connect("mouse_exited",Callable(self,"_on_mouse_exited"))
	
# warning-ignore:return_value_discarded
	connect("updateMainSignal",Callable(mainButton,"update_content"))
# warning-ignore:return_value_discarded
	connect("selectUpdateSignal",Callable(mainButton,"select_update"))
	
	generate_style_boxes()
	
	pass

func init_craftable(craftable:MyCraftable)->void:
	var control = Control.new()
	control.set_custom_minimum_size(Vector2(100,100))
	control.set_name(craftable.get_name())
	control.set_mouse_filter(MOUSE_FILTER_IGNORE)
	var button = create_select_button(craftable.get_name())
	control.add_child(button)
	bar.add_child(control)

func create_select_button(craftableName:String)->Button:
	var button = set_style_boxes(Button.new())
	button.set_custom_minimum_size(Vector2(80,80))
	button.set_position(Vector2(10,10))
	button.set_name(craftableName+" button")
	button.set_mouse_filter(MOUSE_FILTER_PASS)
	button.set_focus_mode(0)
	#button.set_flat(false)
	button.set_script(craftMenuButtonScript)
	button.connect("updateNeeded",Callable(self,"update_main_content"))
	button.connect("selectUpdate",Callable(self,"update_select"))
	button.request_ready()
	return button

func add_to_bar(craftableName:String, craftable:MyCraftable)->void:
	for child in bar.get_children():
		if child.get_name() == craftableName:
			bar.get_node(craftableName).add_child(craftable)
			bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
			return
	print_debug("Can not find place in bar to add craftable: "+craftableName)

func update_at_bar(craftableName:String, craftable:MyCraftable, state:bool)->void:
	for child in bar.get_children():
		if child.get_name() == craftableName:
			bar.get_node(craftableName).add_child(craftable)
			if state:
# warning-ignore:return_value_discarded
				set_style_craftable(bar.get_node(craftableName+"/"+craftableName+" button"))
			elif !state:
# warning-ignore:return_value_discarded
				set_style_boxes(bar.get_node(craftableName+"/"+craftableName+" button"))
			return
	print_debug("Can not find place in bar to update craftable: "+craftableName)

func update_main_content(): # For updating selected button.
	emit_signal("updateMainSignal", "bar")

func update_content(craftable, state)->void: # For updating inside all of one button. Used to sync craftability state.
	var craftableName = craftable.get_name()
	clear_contents(craftableName)
	var dummyCraftable:MyCraftable = GameManager.get_player().get_next_craftables()[craftableName].duplicate()
	dummyCraftable.to_simpleton()
	dummyCraftable.set_position(Vector2(50,50))
	dummyCraftable.set_scale(Vector2(0.01,0.01))
	update_at_bar(craftableName, dummyCraftable, state)

func update_contents(): # For updating inside all the buttons.
	update_main_content()
	for craftableName in GameManager.get_player().get_next_craftables().keys():
		clear_contents(craftableName)
		var dummyCraftable:MyCraftable = GameManager.get_player().get_next_craftables()[craftableName].duplicate()
		dummyCraftable.to_simpleton()
		dummyCraftable.set_position(Vector2(50,50))
		dummyCraftable.set_scale(Vector2(0.01,0.01))
		add_to_bar(craftableName, dummyCraftable)

func update_content_of_node(craftableName:String)->void:
	clear_contents(craftableName)
	var dummyCraftable:MyCraftable = GameManager.get_player().get_next_craftables()[craftableName].duplicate()
	dummyCraftable.to_simpleton()
	dummyCraftable.set_position(Vector2(50,50))
	dummyCraftable.set_scale(Vector2(0.01,0.01))
	add_to_bar(craftableName, dummyCraftable)
	

func clear_contents(craftableName:String)->void:
	for child in bar.get_children():
		if child.has_node(craftableName+" button"):
			for child2 in child.get_children():
				if child2.get_name() != craftableName+" button":
					child2.queue_free()
			return
	print_debug("Can not find craftable to clear in clear contents: "+craftableName)

func update_select(name:String)->void:
	emit_signal("selectUpdateSignal", name, "bar")

func set_style_craftable(button:Button)->Button:
	button.add_theme_stylebox_override('hover', craftableButtonStyleHover)
	button.add_theme_stylebox_override('pressed', craftableButtonStylePressed)
	button.add_theme_stylebox_override('focus', craftableButtonStyleFocus)
	button.add_theme_stylebox_override('disable', craftableButtonStyleDisable)
	button.add_theme_stylebox_override('normal', craftableButtonStyleNormal)
	return button

func set_style_boxes(button:Button)->Button:
	button.add_theme_stylebox_override('hover', buttonStyleHover)
	button.add_theme_stylebox_override('pressed', buttonStylePressed)
	button.add_theme_stylebox_override('focus', buttonStyleFocus)
	button.add_theme_stylebox_override('disable', buttonStyleDisable)
	button.add_theme_stylebox_override('normal', buttonStyleNormal)
	return button

func generate_style_boxes():
	buttonStyleHover.set_bg_color(Color("#2c2e2e2e"))
	buttonStyleHover.set_corner_radius_all(5)
	buttonStylePressed.set_bg_color(Color("#2c3b3b3b"))
	buttonStylePressed.set_corner_radius_all(5)
	buttonStyleDisable.set_bg_color(Color("#0f0f0f"))
	buttonStyleDisable.set_corner_radius_all(4)
	buttonStyleNormal.set_bg_color(Color("#2c272727"))
	buttonStyleNormal.set_corner_radius_all(5)
	craftableButtonStyleHover.set_bg_color(Color("#2ceaeaea"))
	craftableButtonStyleHover.set_corner_radius_all(5)
	craftableButtonStylePressed.set_bg_color(Color("#2cffffff"))
	craftableButtonStylePressed.set_corner_radius_all(5)
	craftableButtonStyleDisable.set_bg_color(Color("#2c0f0f"))
	craftableButtonStyleDisable.set_corner_radius_all(4)
	craftableButtonStyleNormal.set_bg_color(Color("#2cafafaf"))
	craftableButtonStyleNormal.set_corner_radius_all(5)

func scroll_up()->void:
	if get_v_scroll() > 0:
		set_v_scroll(int(get_v_scroll()-get_v_scroll_bar().get_step()))

func scroll_down()->void:
	if get_v_scroll() < self.get_v_scroll_bar().get_max():
		set_v_scroll(int(get_v_scroll()+get_v_scroll_bar().get_step()))

func _input(event):
	if event is InputEventMouseButton:
		if self.get_rect().has_point(Vector2((event.position[0] - self.get_global_position()[0]), (event.position[1] - self.get_global_position()[1]))):
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					self.scroll_up()
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					self.scroll_down()

func _on_mouse_entered():
	mouseIsOverButton = true

func _on_mouse_exited():
	mouseIsOverButton = false

func _on_Up_pressed():
	self.scroll_up()
	pass

func _on_Down_pressed():
	self.scroll_down()
	pass

#func _process(delta):
#	pass

