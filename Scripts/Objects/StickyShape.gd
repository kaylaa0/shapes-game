extends RigidBody2D

var attachedBody
var carryingBody

var justRotated = 10

func _ready():
	pass

func set_attached_body(shape:MyShape):
	attachedBody = shape

func set_carrying_body(shape:MyShape):
	carryingBody = shape

func _integrate_forces(state):
	if attachedBody != null:
		if attachedBody.get_node("RightCast").is_colliding() and justRotated <= 0:
			var xform = state.get_transform().rotated(-0.01)
			state.set_transform(xform)
			justRotated = 2
		elif attachedBody.get_node("LeftCast").is_colliding() and justRotated <= 0:
			var xform = state.get_transform().rotated(0.01)
			state.set_transform(xform)
			justRotated = 2
		elif attachedBody.get_node("TopCastsNode").get_node("TopRightCast").is_colliding() and justRotated <= 0:
			var xform = state.get_transform().rotated(-0.01)
			state.set_transform(xform)
			justRotated = 2
		elif attachedBody.get_node("TopCastsNode").get_node("TopLeftCast").is_colliding() and justRotated <= 0:
			var xform = state.get_transform().rotated(0.01)
			state.set_transform(xform)
			justRotated = 2
		elif attachedBody.get_node("RightCastsNode").get_node("RightUpCast").is_colliding() and justRotated <= 0:
			if rad_to_deg(state.get_transform().get_rotation()) > -90 and rad_to_deg(state.get_transform().get_rotation()) <= -30:
				var xform = state.get_transform().rotated(-0.01)
				state.set_transform(xform)
				justRotated = 2
		elif attachedBody.get_node("LeftCastsNode").get_node("LeftUpCast").is_colliding() and justRotated <= 0:
			if rad_to_deg(state.get_transform().get_rotation()) < 90 and rad_to_deg(state.get_transform().get_rotation()) >= 30:
				var xform = state.get_transform().rotated(0.01)
				state.set_transform(xform)
				justRotated = 2
		elif attachedBody.get_node("UpCast").is_colliding() and justRotated <= 0:
			if rad_to_deg(state.get_transform().get_rotation()) > -90 and rad_to_deg(state.get_transform().get_rotation()) <= -45:
				var xform = state.get_transform().rotated(-0.01)
				state.set_transform(xform)
				justRotated = 2
			elif rad_to_deg(state.get_transform().get_rotation()) < 90 and rad_to_deg(state.get_transform().get_rotation()) >= 45:
				var xform = state.get_transform().rotated(0.01)
				state.set_transform(xform)
				justRotated = 2
			else:
				justRotated = 10
		elif justRotated == -10:
			if state.get_transform().get_rotation() > 0.01:
				var xform = state.get_transform().rotated(-0.01)
				state.set_transform(xform)
				justRotated = -8
			elif state.get_transform().get_rotation() < -0.01:
				var xform = state.get_transform().rotated(0.01)
				state.set_transform(xform)
				justRotated = -8
		if justRotated > -10:
			justRotated -= 1
	
