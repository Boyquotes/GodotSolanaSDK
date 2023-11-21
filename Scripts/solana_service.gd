extends Control

@export var custom_rpc:String

@onready var phantom_controller:PhantomController = $PhantomController

@onready var login_overlay = $OverlayLayer/LoginOverlay
@onready var transaction_overlay = $OverlayLayer/TransactionOverlay

signal on_logged_in

signal on_transaction_finish
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	login_overlay.visible=false
	transaction_overlay.visible=false
	
	if custom_rpc.length() >0:
		SolanaClient.set_url(custom_rpc)
		SolanaClient.set_encoding("base64");
		
	phantom_controller.connect("connection_established",log_in_success)
	phantom_controller.connect("connection_error",log_in_fail)
	phantom_controller.connect("message_signed",process_transaction_pass)
	phantom_controller.connect("signing_error",process_transaction_error)
	
func try_login() -> void:
	login_overlay.visible=true
	phantom_controller.connect_phantom()

func log_in_success() -> void:
	emit_signal("on_logged_in",true)
	login_overlay.visible=false
	
func log_in_fail() -> void:
	emit_signal("on_logged_in",false)
	login_overlay.visible=false
	
func get_connected_address() -> String:
	var address = SolanaSDK.bs58_encode(phantom_controller.get_connected_key())
	return address
	
func get_transaction_id(byte_array:PackedByteArray) -> String:
	var id = SolanaSDK.bs58_encode(byte_array)
	return id

func get_sol_balance() -> float:
	var address = SolanaSDK.bs58_encode(phantom_controller.get_connected_key())
	var response_dict:Dictionary = SolanaClient.get_balance(address)
	var balance = response_dict["result"]["value"] / 1000000000
	return balance
	

func send_transaction(receiver:String,amount:float) -> void:
	transaction_overlay.visible=true
	
	var sender_account = Pubkey.new() 
	sender_account.set_value(get_connected_address())
	
	var receiver_account = Pubkey.new() 
	receiver_account.set_value(receiver)
	
	var amount_in_lamports = int(amount*1000000000)
	
	var sol_transfer_ix:Instruction = SystemProgram.transfer(sender_account,receiver_account,amount_in_lamports)

	var transaction:Transaction = Transaction.new()	
	transaction.add_instruction(sol_transfer_ix)
	
	transaction.use_phantom_payer = true
	transaction.set_payer(phantom_controller)

	transaction.update_latest_blockhash("")
	
	await transaction.sign_and_send()
	
func process_transaction_pass(transaction_byte_array:PackedByteArray) -> void:	
	transaction_overlay.visible=false
	emit_signal("on_transaction_finish",get_transaction_id(transaction_byte_array))
	

func process_transaction_error() -> void:	
	transaction_overlay.visible=false
	emit_signal("on_transaction_finish",null)
