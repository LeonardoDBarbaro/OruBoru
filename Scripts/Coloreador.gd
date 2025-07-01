extends Node3D

@export var cabeza  : Array[NodePath]
@export var anillos : Array[NodePath]
@export var brazos  : Array[NodePath]
@export var piernas : Array[NodePath]
@export var manos   : Array[NodePath]
@export var pies    : Array[NodePath]

@export var colores : Array[Color] = [
	Color(1, 0.8, 0.6),   # 0 → cabeza
	Color(1, 0.9, 0.4),   # 1 → anillos
	Color(0.8, 0.2, 0.2), # 2 → brazos
	Color(0.2, 0.3, 0.9), # 3 → piernas
	Color(0.9, 0.6, 0.2), # 4 → manos
	Color(0.2, 0.8, 0.3)  # 5 → pies
]

func _ready() -> void:
	var tablas := [
		{ "paths": cabeza,  "color_index": 0 },
		{ "paths": anillos, "color_index": 1 },
		{ "paths": brazos,  "color_index": 2 },
		{ "paths": piernas, "color_index": 3 },
		{ "paths": manos,   "color_index": 4 },
		{ "paths": pies,    "color_index": 5 }
	]

	for entrada in tablas:
		var lista_paths : Array[NodePath] = entrada["paths"]
		var idx : int = entrada["color_index"]
		var color
		if colores.size() > idx :
			color = colores[idx]
		else:
			color = Color.WHITE
		var material := _crear_material(color)

		for path in lista_paths:
			var mesh := get_node_or_null(path)
			if mesh is MeshInstance3D:
				_pintar_mesh_completa(mesh, material)

func _pintar_mesh_completa(mesh: MeshInstance3D, mat: Material) -> void:
	if mesh.mesh == null:
		return
	for s in mesh.mesh.get_surface_count():
		mesh.set_surface_override_material(s, mat)

func _crear_material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return m
	
func _jaja(equipo):
	var palette = equipo.colores
	var tablas := [
		{ "paths": cabeza,  "color_index": 0 },
		{ "paths": anillos, "color_index": 1 },
		{ "paths": brazos,  "color_index": 2 },
		{ "paths": piernas, "color_index": 3 },
		{ "paths": manos,   "color_index": 4 },
		{ "paths": pies,    "color_index": 5 }
	]

	for entrada in tablas:
		var idx : int                = entrada["color_index"]
		var lista_paths : Array      = entrada["paths"]

		for path: NodePath in lista_paths:
			var nodo := get_node_or_null(path)
			if nodo == null:
				push_warning("No se encontró el nodo %s" % path)
				continue
			var mat = nodo.get_active_material(0)
			mat.albedo_color = palette[idx]
			
func _on_scroll_colores_equipo_cambiado(equipo_node: Variant,value) -> void:
	_jaja(equipo_node)
