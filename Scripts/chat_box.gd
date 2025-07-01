extends VBoxContainer

@onready var chat = $Chat
@onready var historial = $Historial

func _on_chat_text_submitted(new_text):
	var formateoNombre = "\n<"+name+">: "
	historial.append_text(formateoNombre+chat.text)
	chat.clear()
