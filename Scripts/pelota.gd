extends RigidBody3D
class_name NetworkInterpolatedBall

const MAX_SNAPSHOTS = 3
var snapshots := []
var last_pos = Vector3.ZERO
var last_velocity := Vector3.ZERO

@export var interpolation_speed := 10.0
var send_timer := 0.0
const SNAPSHOT_INTERVAL := 0.05

@export var max_speed: float = 20
@export var max_angular_speed: float = 10.0
@export var linear_stop_threshold: float = 5.0
@export var angular_stop_threshold: float = 10.0
@export var linear_damping_strength: float = 2.0
@export var angular_damping_strength: float = 2.0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var velocity = state.linear_velocity
	var speed = velocity.length()
	var ang_vel = state.angular_velocity
	var ang_speed = ang_vel.length()
	
	if speed > max_speed:
		velocity = velocity.normalized() * max_speed
		state.linear_velocity = velocity
	elif speed < linear_stop_threshold and speed > 0.01:
		var damped = velocity - velocity.normalized() * linear_damping_strength * state.step
		state.linear_velocity = damped if damped.dot(velocity) > 0 else Vector3.ZERO

	if ang_speed > max_angular_speed:
		state.angular_velocity = ang_vel.normalized() * max_angular_speed
	elif ang_speed < angular_stop_threshold and ang_speed > 0.005:
		var damped_ang = ang_vel - ang_vel.normalized() * angular_damping_strength * state.step
		state.angular_velocity = damped_ang if damped_ang.dot(ang_vel) > 0 else Vector3.ZERO


var original_scale := Vector3.ONE

func _ready():
	original_scale = scale

	if !multiplayer.is_server():
		for i in range(MAX_SNAPSHOTS):
			snapshots.append({
				"position": global_transform.origin,
				"rotation": global_transform.basis.get_rotation_quaternion()
			})

func _physics_process(delta):
	var pos = global_transform.origin
	var velocity = (pos - last_pos) / delta
	last_pos = pos
	if multiplayer.is_server():
		send_timer += delta
		if send_timer >= SNAPSHOT_INTERVAL:
			send_timer = 0.0
			send_snapshot()
	else:
		interpolate_snapshots(delta)
		
	var shader_mat := $MeshInstance3D.material_override as ShaderMaterial
	if shader_mat:
		var local_velocity = global_transform.basis.inverse() * velocity
		shader_mat.set_shader_parameter("velocity", local_velocity)

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

	# Aplicar shader con la velocidad real enviada por el servidor
	var shader_mat := $MeshInstance3D.material_override as ShaderMaterial
	if shader_mat and to.has("velocity"):
		var local_velocity = global_transform.basis.inverse() * to.velocity
		shader_mat.set_shader_parameter("velocity", local_velocity)

@rpc("call_local")
func update_snapshot(pos: Vector3, rot: Quaternion, vel: Vector3):
	if multiplayer.is_server():
		return

	snapshots.insert(0, {
		"position": pos,
		"rotation": rot,
		"velocity": vel
	})

	if snapshots.size() > MAX_SNAPSHOTS:
		snapshots.pop_back()

@rpc("authority")
func send_snapshot():
	var pos = global_transform.origin
	var rot = global_transform.basis.get_rotation_quaternion()
	var vel = linear_velocity  # velocidad real de Godot
	last_velocity = vel  # lo guarda por si lo necesitás localmente
	rpc("update_snapshot", pos, rot, vel)
