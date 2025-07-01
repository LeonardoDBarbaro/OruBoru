extends Node

const DEFAULTS := {
	"ModoPantalla":  1,
	"Calidad":       2,
	"Resolucion":    0,
	"Musica":        70,
	"Sonido":        70,
	"Sensibilidad":  100,
	"Nombre":        "Jugador",
	"Equipos": [
		["Leones",    "LEO", [Color.RED,  Color.ORANGE, Color.YELLOW, Color.AQUA, Color.AZURE, Color.BLUE_VIOLET]],
		["Tiburones", "TIB", [Color.BLUE, Color.CYAN,   Color.GRAY, Color.RED,  Color.ORANGE, Color.YELLOW]]
	]
}

var current = DEFAULTS.duplicate()

var keys : Array[StringName] = [
	"ModoPantalla",
	"Calidad",
	"Resolucion",
	"Musica",
	"Sonido",
	"Sensibilidad",
	"Nombre"
]

func _ready():
	cargar_configuracion()

func reset():
	current = DEFAULTS.duplicate()

func set_opcion(clave: StringName, valor):
	current[clave] = valor

func get_opcion(clave: StringName):
	return current[clave]
	
func guardar_configuracion():
	var config := ConfigFile.new()
	for clave in current:
		config.set_value("Opciones", clave, current[clave])
	
	var err = config.save("user://oruboru.sav")
	if err != OK:
		push_error("Error al guardar configuración: %s" % err)

func cargar_configuracion():
	var config := ConfigFile.new()
	var err = config.load("user://oruboru.sav")
	
	if err != OK:
		print("No se encontró oruboru.sav, se usarán valores por defecto")
		current = DEFAULTS.duplicate()
		return
	
	for clave in DEFAULTS:
		if config.has_section_key("Opciones", clave):
			current[clave] = config.get_value("Opciones", clave)
		else:
			current[clave] = DEFAULTS[clave]
