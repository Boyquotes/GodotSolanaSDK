extends Node

@onready var welcome_label:Label = $AccountPanel/WelcomeLabel
@onready var sol_balance:Label = $AccountPanel/BalanceLabel/Balance

var solana_service
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solana_service = get_node("/root/SolanaService")
	welcome_label.text = "Welcome back,\n%s" % [solana_service.get_connected_address()]
	sol_balance.text = str(solana_service.get_sol_balance())
