extends Control

@onready var nodoActual
@onready var Contenedor = get_node("ScrollContainer/HBoxContainer")
@onready var nodoTemplate = Contenedor.get_node("Template")
@onready var sc = get_node("ScrollContainer")
@onready var cp

static var equipos_totales: Array = []

var equipoPredeterminado = Equipo.new("Nombre","ABV", [Color.GRAY,Color.GRAY,Color.GRAY,Color.GRAY,Color.GRAY,Color.GRAY])

signal equipo_cambiado(equipo_node,posicion)

func _ready():
	var abuelo = get_parent().get_parent()
	if abuelo:
		cp = abuelo.get_node_or_null("ColorPicker")
		if cp:
			cp.connect("shader_modificado", Callable(self,"_on_scroll_fin2"))
	sc.connect("scroll_completado", Callable(self, "_on_scroll_fin"))

	var equipos_totales = deserializar_equipos(Save.get_opcion("Equipos"))
	llenarEquipos(equipos_totales)
	
func llenarEquipos(Equipos):
	for equipo in Equipos:
		crearEquipo(equipo,false,false)
		
func crearEquipo(equipo,delanteDelCentrado,nuevoEquipo):
	var nuevo = nodoTemplate.duplicate()
	var nuevoRect = nuevo.get_node("1")
	nuevoRect.material = nuevoRect.material.duplicate()
	nuevo.visible = true
	Contenedor.add_child(nuevo)
	if delanteDelCentrado:
		nodoActual = get_node("ScrollContainer").get_nodo_centrado()
		var index = nodoActual.get_index()
		Contenedor.move_child(nuevo,index)
	else:
		Contenedor.move_child(nuevo,1)
	if nuevoEquipo:
		nuevo.set_equipo(equipoPredeterminado)
	else:
		nuevo.set_equipo(equipo)
	return nuevo
		
func setNodoActual(equipo):
	nodoActual = get_node("ScrollContainer").get_nodo_centrado()
	nodoActual.set_equipo(equipo)
	
func getNodoActual():
	nodoActual = get_node("ScrollContainer").get_nodo_centrado()
	return nodoActual
	
func eliminarNodoActual():
	nodoActual = get_node("ScrollContainer").get_nodo_centrado()
	if get_node("ScrollContainer/HBoxContainer").get_child_count() > 5:
		nodoActual.queue_free()

func _on_scroll_fin(nodo_centrado : Control):
	emit_signal("equipo_cambiado", nodo_centrado.get_equipo(), 0)
	
func _on_scroll_fin2(nodo_centrado : Control):
	emit_signal("equipo_cambiado", nodo_centrado.get_equipo(), 1)
	
func obtener_todos_los_equipos() -> Array:
	var lista_equipos = []
	for nodo in Contenedor.get_children():
		if nodo.has_method("get_equipo") and nodo.visible:
			lista_equipos.append(nodo.get_equipo())
			print(nodo.get_equipo().nombre)
	return lista_equipos
	
func limpiarEquipos():
	for nodo in Contenedor.get_children():
		if nodo.visible and nodo.has_method("get_equipo"):
			nodo.queue_free()

func _on_equipos_toggled(toggled_on: bool):
	if toggled_on:
		sc.scroll_to(sc.scroll_horizontal)

func _on_draw() -> void:
	if get_parent().name == 'DER':
		sc.scroll_to(0,0)
		sc.scroll_to(sc.get_child_size(),0)
	if get_parent().name == "IZQ":
		sc.scroll_to(0,0)

func _on_nuevo_pressed() -> void:
	crearEquipo(equipoPredeterminado,1,true)
	sc.scroll_to(sc.scroll_horizontal,0)
	actualizarEquipos()
	guardar_equipos()
	
func _on_borrar_pressed() -> void:
	eliminarNodoActual()
	sc.scroll_to(sc.scroll_horizontal,0)
	actualizarEquipos()
	guardar_equipos()

func _on_hidden() -> void:
	if get_parent().name == "Selector":
		actualizarEquipos()
		guardar_equipos()

func actualizarEquipos():
		equipos_totales = obtener_todos_los_equipos()
		var IZQ = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("MenuCrearPartida2/IZQ/ScrollColores")
		var DER = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("MenuCrearPartida2/DER/ScrollColores")
		IZQ.limpiarEquipos()
		IZQ.llenarEquipos(equipos_totales)
		DER.limpiarEquipos()
		DER.llenarEquipos(equipos_totales)
		
func serializar_equipos(equipos: Array) -> Array:
	var serializados = []
	for eq in equipos:
		serializados.append([eq.nombre, eq.abreviacion, eq.colores])
	return serializados
	
func deserializar_equipos(data: Array) -> Array:
	var lista = []
	for item in data:
		var nombre = item[0]
		var abv = item[1]
		var colores = []
		for c_str in item[2]:
			colores.append(Color(c_str))
		var colores_typed = PackedColorArray(colores)	
		lista.append(Equipo.new(nombre, abv, colores_typed))
	return lista

func guardar_equipos():
	var serializados = serializar_equipos(equipos_totales)
	Save.set_opcion("Equipos", serializados)
	Save.guardar_configuracion()
