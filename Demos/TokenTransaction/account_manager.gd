extends Node

@onready var account_address:Label = $AccountAddress
@onready var sol_balance:Label = $Balance

var solana_service
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solana_service = get_node("/root/SolanaService")
	account_address.text = solana_service.get_connected_address()
	sol_balance.text = str(solana_service.get_sol_balance())
