extends Control

var _equipo : Equipo

@onready var mat         = get_node("1").material
@onready var lbl_nombre  = get_node("nombre")
@onready var lbl_abrev   = get_node("abreviacion")

func set_equipo(equipo: Equipo) -> void:
	_equipo = equipo
	print("jaja")
	_actualizar_visual()
	
func get_equipo():
	return _equipo

func _actualizar_visual() -> void:
	lbl_nombre.text  = _equipo.nombre
	lbl_abrev.text   = _equipo.abreviacion
	
	if _equipo.colores.size() >= 1:
		mat.set_shader_parameter("center_color", _equipo.colores[0])

	for i in range(5): 
		var color_index = i + 1
		if color_index < _equipo.colores.size():
			mat.set_shader_parameter("slice%d_color" % i, _equipo.colores[color_index])
