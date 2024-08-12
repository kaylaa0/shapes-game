extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RichTextLabel_meta_hover_started(meta):
	print(2222)
	pass # Replace with function body.


func _on_RichTextLabel_mouse_entered():
	print(123)
	pass # Replace with function body.
