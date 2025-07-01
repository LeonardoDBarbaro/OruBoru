extends AnimatedSprite3D

@onready var iris = $Iris

const ROT_MIN_X = deg_to_rad(-30)
const ROT_MAX_X = deg_to_rad(30)
const STIFFNESS := 60.0
const DAMPING := 10.0
const MASS := 1.0

var OFFSET_MIN_Y := 1.0
var OFFSET_MAX_Y := -2.0
var velocity := 0.0
var current_y := OFFSET_MAX_Y / 2
var camera
var valorPestañeo = 0

func _ready():
	camera = get_camera_node()

func _process(delta):	
	var factor = inverse_lerp(ROT_MIN_X, ROT_MAX_X, camera.rotation.x)
	factor = clamp(factor, 0.0, 1.0)
	var target_y = lerp(OFFSET_MIN_Y, OFFSET_MAX_Y, factor)

	var displacement = current_y - target_y
	var spring_force = -STIFFNESS * displacement
	var damping_force = -DAMPING * velocity
	var force = spring_force + damping_force
	var acceleration = force / MASS

	velocity += acceleration * delta
	current_y += velocity * delta

	var pos = iris.position
	pos.y = current_y
	iris.position = pos
	
	input()
		
var tiempo_para_proximo_pestaneo = randf_range(3.0, 5.0)
var temporizador_pestaneo = 0.0

func _physics_process(delta):
	temporizador_pestaneo += delta

	if temporizador_pestaneo >= tiempo_para_proximo_pestaneo:
		pestañear(true)
		await get_tree().create_timer(0.125).timeout
		pestañear(false)
		temporizador_pestaneo = 0.0
		tiempo_para_proximo_pestaneo = randf_range(3.0, 5.0)
	
func pestañear(boolin):
	if boolin == true:
		iris.set_frame_and_progress(1,0)
	else:
		iris.set_frame_and_progress(0,0)

func input():
	if Input.is_key_pressed(KEY_1):
		set_frame_and_progress(0,1)

	if Input.is_key_pressed(KEY_2):
		set_frame_and_progress(1,2)		
		
	if Input.is_key_pressed(KEY_3):
		set_frame_and_progress(2,0)
		
	if Input.is_key_pressed(KEY_4):
		set_frame_and_progress(4,0)

func get_camera_node() -> Camera3D:
	var node = get_parent().get_node("Ojos") 
	while node:
		if node.has_node("Camera3D"):
			return node.get_node("Camera3D") as Camera3D
		node = node.get_parent()
	push_error("Camera3D no encontrada en la jerarquía.")
	return null
