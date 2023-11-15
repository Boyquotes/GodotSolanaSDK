extends Node

@onready var receiver_input:LineEdit = $ReceiverInputField
@onready var amount_input:LineEdit = $AmountInputField
@onready var send_button:Button = $SendButton

@onready var LineEditRegEx = RegEx.new()

var solana_client
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LineEditRegEx.compile("^[0-9.]*$")
	
	solana_client = get_node("/root/SolanaClient")
	solana_client.connect("on_transaction_finish", transaction_finish_callback)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if receiver_input.text.length()==44 && float(amount_input.text)>0:
		send_button.disabled=false
	else:
		send_button.disabled=true


func _on_send_button_pressed() -> void:
	var test_receiver = "FXyyJSV6Xan9Kf275pryFMFsXBtjWA7HWghF1fTm6ZxJ"
	var test_amount = 0.1
#	solana_client.send_transaction(str(receiver_input.text),float(amount_input.text))
	solana_client.send_transaction(test_receiver,test_amount)
	pass
	
func transaction_finish_callback(success:bool) -> void:
	if success:
		receiver_input.clear()
		amount_input.clear()
	


var old_amount_text = ""
func _on_amount_input_field_text_changed(new_text: String) -> void:
	if LineEditRegEx.search(new_text):
		old_amount_text = str(new_text)
	else:
		amount_input.text = old_amount_text
		amount_input.set_cursor_position(amount_input.text.length())


var old_receiver_text=""
func _on_receiver_input_field_text_changed(new_text: String) -> void:
	if new_text.length()<=44:
		old_receiver_text = new_text
	else:
		receiver_input.text = old_receiver_text
		receiver_input.set_cursor_position(receiver_input.text.length())
