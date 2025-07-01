extends CharacterBody3D

@onready var camera	= $Camera3D
@onready var animation = $AnimationPlayer
@onready var animTimer = $AnimTimer
var team_sync

signal jumped
signal jumped2
signal landed
signal running
signal cameraMov
signal kickL
signal kickR
signal Triste

const SPEED = 16
var destino = null
const JUMP_VELOCITY = 10
const SENSITIVTY =  0.005
var fuerza = 0
var patear = false
var piso = false
var jumpAnim = false
var celebration_played = false
var jumps_left = 2
var camMov = 0
var tiene_pelota = false
var ball
var triste = false

const MAX_SNAPSHOTS = 3
const SNAPSHOT_INTERVAL := 0.05

@export var interpolation_speed := 5.0

var snapshots := []
var send_timer := 0.0
var original_scale := Vector3.ONE

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animTimer.set_wait_time(0.2)
	animTimer.set_one_shot(true)
	animTimer.start()
	if is_multiplayer_authority():
		camera.current = true
	else:
		camera.current = false
		
	original_scale = scale
	if !is_multiplayer_authority():
		for i in range(MAX_SNAPSHOTS):
			snapshots.append({
				"position": global_transform.origin,
				"rotation": global_transform.basis.get_rotation_quaternion()
			})
	
func _physics_process(delta):
	if is_multiplayer_authority():
		send_timer += delta
		if send_timer >= SNAPSHOT_INTERVAL:
			send_timer = 0.0
			send_snapshot()
	else:
		interpolate_snapshots(delta)
		return
		
	if destino != null and global_position.distance_to(destino) > 0.2:
		var dir = (destino - global_position)
		dir.y = 0
		if not is_on_floor():
			velocity += get_gravity() * delta * 2
		if dir.length() > 0.1:
			look_at(global_position + dir.normalized(), Vector3.UP)
			if is_multiplayer_authority():
				camera.rotation.x = deg_to_rad(-10)
				camera.rotation.y = 0

		var vel = dir.normalized() * SPEED
		velocity.x = vel.x
		velocity.z = vel.z

		update_animation()
		move_and_slide()

		if global_position.distance_to(destino) < 0.2:
			velocity = Vector3.ZERO
			destino = null
			_mirar_al_centro()
		return
			
	if ball != null:
		var raycast = get_node("RayCast3D")
		var target = ball.global_transform.origin
		var new_pos = raycast.global_transform.origin
		var base_y = global_transform.origin.y
		new_pos.y = clamp(target.y, base_y - 0.5, base_y + .5)
		raycast.global_transform.origin = new_pos
		raycast.look_at(target)
	
	movimiento(delta)

	update_animation()
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		emit_signal("kickL")
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		emit_signal("kickR")

	move_and_slide()

	for i in get_slide_collision_count():
		var sCollision = get_slide_collision(i)
		var sCollider = sCollision.get_collider()
		if sCollider.is_in_group("pelota") and get_node("RayCast3D").get_collision_normal().y < 0.7:
			var impulso = (-sCollision.get_normal())
			rpc_id(1, "_patear_pelota", sCollider.get_path(), impulso)
			sCollider.apply_central_impulse(impulso) 

func interpolate_snapshots(delta):
	if snapshots.size() < 2:
		return
	var from = snapshots[1]
	var to = snapshots[0]
	var new_position = global_transform.origin.lerp(to.position, delta * interpolation_speed)
	var current_rot = global_transform.basis.get_rotation_quaternion()
	var target_rot = to.rotation
	var new_rot = current_rot.slerp(target_rot, delta * interpolation_speed)
	var new_basis = Basis(new_rot).scaled(original_scale)
	global_transform = Transform3D(new_basis, new_position)


func update_animation():
	if is_on_floor() and abs(velocity.x)+abs(velocity.z) > 0:
		emit_signal("running")

	elif is_on_floor():
		if camMov > 15:
			emit_signal("cameraMov")
		else:
			if triste:
				emit_signal("Triste")
			else:
				emit_signal("landed")
		camMov = 0

	else:
		if jumps_left == 1:
			emit_signal("jumped")
			jumpAnim = true
		else:
			if jumpAnim == true:
				emit_signal("jumped2")
				jumpAnim = false
				
func _unhandled_input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			camera_movement(event)
			
		if event is InputEventMouseButton and event.pressed:
			var raycast = get_node("RayCast3D")
			if raycast.is_colliding():
				var body = raycast.get_collider()
				if body is RigidBody3D:
					var jorge = -raycast.get_collision_normal()
					jorge.y = 0  # Descartamos la componente vertical de la normal
					if Input.is_action_pressed("TiroAlto"):
						var impulse = jorge * 5 + Vector3(0, 15, 0)  # Impulso hacia arriba
						rpc_id(1, "_patear_pelota", body.get_path(), impulse)
						if not multiplayer.is_server():
							body.apply_central_impulse(impulse) 
					else:
						var impulse = jorge * 40 + Vector3(0, 4, 0) # Solo empujar en la dirección de la normal
						rpc_id(1, "_patear_pelota", body.get_path(), impulse)
						if not multiplayer.is_server():
							body.apply_central_impulse(impulse) 
	
func camera_movement(event):
	rotate_y(-event.relative.x * SENSITIVTY)
	camera.rotate_x(-event.relative.y * SENSITIVTY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(65))
	camMov = abs(event.relative.x)

func movimiento(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
	else:
		jumps_left = 2 

	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		emit_signal("jumped")

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("pelota"):
		get_node("RayCast3D").look_at(body.global_transform.origin)
		ball = body

@rpc("authority", "call_local")
func _patear_pelota(pelota_path: NodePath, impulso: Vector3):
	var pelota = get_node(pelota_path)
	if pelota:
		pelota.apply_central_impulse(impulso)

@rpc("call_local")
func update_snapshot(pos: Vector3, rot: Quaternion):
	if is_multiplayer_authority(): return

	snapshots.insert(0, {
		"position": pos,
		"rotation": rot
	})
	if snapshots.size() > MAX_SNAPSHOTS:
		snapshots.pop_back()

@rpc("authority")
func send_snapshot():
	var pos = global_transform.origin
	var rot = global_transform.basis.get_rotation_quaternion()
	rpc("update_snapshot", pos, rot)

@rpc("call_remote")
func recibir_teams(equipos: Dictionary):
	for jugador_nombre in equipos:
		var team = equipos[jugador_nombre]
		var jugador = get_node_or_null(jugador_nombre)
		if jugador:
			jugador.set_team(team)  # Actualiza color, posición o lo que corresponda
	
@rpc("any_peer", "reliable")
func mover_a(pos: Vector3):
	global_position = pos
	look_at(Vector3(0, pos.y, 0), Vector3.UP)
	
@rpc("any_peer", "reliable")
func ir_a(pos: Vector3):
	destino = pos
	destino.y = -4.06 #y del suelo en mapa1
	
func _mirar_al_centro():
	var centro = Vector3(0, global_position.y, 0)
	look_at(centro, Vector3.UP)
	if is_multiplayer_authority() and camera:
		camera.rotation.x = deg_to_rad(-10)
		camera.rotation.y = 0
	triste = false

@rpc
func saltar():
	velocity.y = 10
	emit_signal("jumped")
	
@rpc
func ponerse_triste():
	triste = true

	
