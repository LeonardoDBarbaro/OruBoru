extends Control

@onready var sliderR = get_node("SlidersColor/SliderR")
@onready var sliderG = get_node("SlidersColor/SliderG")
@onready var sliderB = get_node("SlidersColor/SliderB")
@onready var hexText = get_node("Hex")
@onready var color

func _ready():
	visible = false
	
func set_color(colorElegido: Color):
	sliderR.value = int(round(colorElegido.r * 255.0))
	sliderG.value = int(round(colorElegido.g * 255.0))
	sliderB.value = int(round(colorElegido.b * 255.0))
	hexText.text = "%02X%02X%02X" % [sliderR.value, sliderG.value, sliderB.value]
	
func _on_hex_editing_toggled(_toggled_on):
	if hexText.text.length() == 6:
		sliderR.value = hexText.text.left(2).hex_to_int()
		sliderG.value = hexText.text.substr(2,2).hex_to_int()
		sliderB.value = hexText.text.right(2).hex_to_int()
