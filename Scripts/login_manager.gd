extends Node

@export var scene_to_load:PackedScene

var wallet_controller
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wallet_controller = get_node("/root/SolanaClient")
	wallet_controller.connect("on_logged_in",confirm_login)	


func confirm_login(login_success:bool) -> void:
	get_tree().change_scene_to_packed(scene_to_load)


func _on_login_button_pressed() -> void:
	wallet_controller.try_login()
