extends Control

@export var custom_rpc:String

@onready var phantom_controller:PhantomController = $PhantomController
@onready var ui_overlay = $TransactionOverlay
signal on_logged_in

signal on_transaction_finish
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_overlay.visible=false
	
	if custom_rpc.length() >0:
		SolanaClient.set_url(custom_rpc)
		
	phantom_controller.connect("connection_established",log_in_success)
	phantom_controller.connect("connection_error",log_in_fail)
	phantom_controller.connect("message_signed",process_transaction_pass)
	phantom_controller.connect("signing_error",process_transaction_error)
	
func try_login() -> void:
	ui_overlay.visible=true
	phantom_controller.connect_phantom()

func log_in_success() -> void:
	emit_signal("on_logged_in",true)
	ui_overlay.visible=false
	
func log_in_fail() -> void:
	emit_signal("on_logged_in",false)
	ui_overlay.visible=false
	
func get_public_key() -> String:
	var address = SolanaSDK.bs58_encode(phantom_controller.get_connected_key())
	return address

func get_sol_balance() -> float:
	var address = SolanaSDK.bs58_encode(phantom_controller.get_connected_key())
	var response_dict:Dictionary = SolanaClient.get_balance(address)
	var balance = response_dict["result"]["value"] / 1000000000
	return balance
	
func send_transaction(receiver:String,amount:float) -> void:
	
	ui_overlay.visible=true
	
	var transaction:Transaction = Transaction.new()
	
	var instructions:Array[Instruction]
	var sol_transfer_ix:Instruction = Instruction.new()
	
	var PID := Pubkey.new()
	PID.set_value("11111111111111111111111111111111") 
	sol_transfer_ix.program_id = PID
	print(sol_transfer_ix.program_id)
	var packed_send_amount:PackedByteArray = pack_send_amount(int(amount*1000000000))
	
	var ix_data:PackedByteArray = PackedByteArray()
	ix_data.resize(12)
	ix_data[0] = 2
	ix_data[1] = packed_send_amount[0]
	ix_data[2] = packed_send_amount[1]
	ix_data[3] = packed_send_amount[2]
	ix_data[4] = packed_send_amount[3]
	sol_transfer_ix.data = ix_data
	

	var receiver_account=AccountMeta.new() as AccountMeta
	receiver_account.key = SolanaSDK.bs58_decode(receiver)
	sol_transfer_ix.accounts.append(receiver_account)
	
	instructions.append(sol_transfer_ix)
	transaction.set_instructions(instructions)
	transaction.use_phantom_payer = true
	transaction.set_payer(phantom_controller)
	transaction.create_message()
	transaction.update_latest_blockhash("")
	print(transaction.serialize())
	transaction.sign()
	await transaction.fully_signed
	transaction.send()
	
func process_transaction_pass(transaction_id:PackedByteArray) -> void:	
	emit_signal("on_transaction_finish",transaction_id)

func process_transaction_error() -> void:	
	emit_signal("on_transaction_finish",null)
	
func pack_send_amount(lamports_to_send:int)->PackedByteArray:
	var byte_array:PackedByteArray = PackedByteArray()
	byte_array.resize(4)
	byte_array[0] = lamports_to_send >> 24
	byte_array[1] = lamports_to_send >> 16
	byte_array[2] = lamports_to_send >> 8
	byte_array[3] = lamports_to_send
	
	return byte_array
