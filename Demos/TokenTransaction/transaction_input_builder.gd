extends Node

@onready var receiver_input:TextEdit = $ReceiverInputField
@onready var amount_input:TextEdit = $AmountInputField

var solana_client
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solana_client = get_node("/root/SolanaClient")
	solana_client.connect("on_transaction_finish", transaction_finish_callback)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_send_button_pressed() -> void:
	solana_client.send_transaction(str(receiver_input.text),float(amount_input.text))
	pass
	
func transaction_finish_callback(success:bool) -> void:
	if success:
		receiver_input.clear()
		amount_input.clear()
	

