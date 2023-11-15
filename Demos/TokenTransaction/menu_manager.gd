extends Node

@onready var welcome_label:Label = $AccountPanel/WelcomeLabel
@onready var sol_balance:Label = $AccountPanel/BalanceLabel/Balance

var solana_client
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solana_client = get_node("/root/SolanaClient")
	welcome_label.text = "Welcome back,\n%s" % [solana_client.get_public_key()]
	sol_balance.text = str(solana_client.get_sol_balance())
