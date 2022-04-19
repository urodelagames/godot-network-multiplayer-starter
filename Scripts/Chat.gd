extends Control

onready var world = get_tree().get_root().get_node("World")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if not visible:
			show()
			$LineEdit.grab_focus()
		else:
			var message_to_send: String = $LineEdit.get_text()
			if not message_to_send.empty():
				$"/root/Network".send_message(message_to_send, get_tree().get_network_unique_id())
				world.get_player().set_message_label(message_to_send)
				$LineEdit.clear()
				
			hide()
				
				
