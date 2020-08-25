extends Camera2D

export var panSpeed = 10.0
export var speed = 10.0
export var zoomspeed = 10.0
export var zoommargin = 0.1

export var zoomMin = 0.5
export var zoomMax = 3.0

export var marginX = 200.0
export var marginY = 100.0

var mousepos = Vector2()
var mouseposGlobal = Vector2()

var startDrag = Vector2()
var startDragV = Vector2()
var endDrag = Vector2()
var endDragV = Vector2()
var is_dragging = false

var zoompos = Vector2()
var zoomfactor = 1.0
var zooming = false

signal area_selected


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_selected", get_parent(), "area_selected", [self])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var inputX = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var inputY = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	position.x = lerp(position.x, position.x + inputX * speed * zoom.x, speed * delta)
	position.y = lerp(position.y, position.y + inputY * speed * zoom.y, speed * delta)

	if Input.is_key_pressed(KEY_CONTROL):
		if mousepos.x < marginX:
			position.x = lerp(
				position.x,
				position.x - abs(mousepos.x - marginX) / marginX * panSpeed * zoom.x,
				panSpeed * delta
			)
		elif mousepos.x > OS.window_size.x - marginX:
			position.x = lerp(
				position.x,
				(
					position.x
					+ abs(mousepos.x - OS.window_size.x + marginX) / marginX * panSpeed * zoom.x
				),
				panSpeed * delta
			)
		if mousepos.y < marginY:
			position.y = lerp(
				position.y,
				position.y - abs(mousepos.y - marginY) / marginY * panSpeed * zoom.y,
				panSpeed * delta
			)
		elif mousepos.y > OS.window_size.y - marginY:
			position.y = lerp(
				position.y,
				(
					position.y
					+ abs(mousepos.y - OS.window_size.y + marginY) / marginY * panSpeed * zoom.y
				),
				panSpeed * delta
			)

	# Created in Project > Project Settings > Input Map 
	if Input.is_action_just_pressed("ui_left_mouse_button"):
		startDrag = mouseposGlobal
		startDragV = mousepos
		is_dragging = true

	if is_dragging:
		endDrag = mouseposGlobal
		endDragV = mousepos

	if Input.is_action_just_released("ui_left_mouse_button"):
		if startDragV.distance_to(mousepos) > 20:
			endDrag = mouseposGlobal
			endDragV = mousepos
			is_dragging = false
#			emit_signal("area_selected")
		else:
			endDrag = startDrag
			is_dragging = false

	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, zoomspeed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, zoomspeed * delta)

	zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	zoom.y = clamp(zoom.y, zoomMin, zoomMax)
#
	if not zooming:
		zoomfactor = 1.0


func _input(event):
	if abs(zoompos.x - get_global_mouse_position().x) > zoommargin:
		zoomfactor = 1.0
	if abs(zoompos.y - get_global_mouse_position().y) > zoommargin:
		zoomfactor = 1.0

	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.button_index == BUTTON_WHEEL_UP:
				zoomfactor -= 0.01 * zoomspeed
				zoompos = get_global_mouse_position()
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoomfactor += 0.01 * zoomspeed
				zoompos = get_global_mouse_position()
		else:
			zooming = false

	if event is InputEventMouse:
		mousepos = event.position
