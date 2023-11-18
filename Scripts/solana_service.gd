extends Control

@export var custom_rpc:String

@onready var phantom_controller:PhantomController = $PhantomController
@onready var ui_overlay = $TransactionOverlay

@onready var sol_transfer_transaction:Transaction = $SolTransferTransaction
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
	
	ui_overlay.visible=true
	
	var transaction:Transaction = Transaction.new()
	
	var instructions:Array[Instruction]
	var sol_transfer_ix:Instruction = Instruction.new()
	
	var program_id := Pubkey.new()
	program_id.set_value("1111111111111111111111111111111") 
	sol_transfer_ix.program_id = program_id
	sol_transfer_ix.data = pack_transfer_amount(amount)
	print(sol_transfer_ix.program_id.get_bytes().size())
	
	var sender_account = AccountMeta.new() as AccountMeta
	sender_account.key = Pubkey.new() 
	sender_account.key.set_value(get_connected_address())

	sender_account.writeable = true
#
	var receiver_account=AccountMeta.new() as AccountMeta
	receiver_account.key = Pubkey.new()
	receiver_account.key.set_value(receiver) 

	receiver_account.writeable = true

	sol_transfer_ix.set_accounts([sender_account,receiver_account])
	
	instructions.append(sol_transfer_ix)
	transaction.set_instructions(instructions)
	transaction.use_phantom_payer = true
	transaction.set_payer(phantom_controller)

	transaction.update_latest_blockhash("")
	
	transaction.sign()
	await transaction.fully_signed
	transaction.send()
	
func process_transaction_pass(transaction_byte_array:PackedByteArray) -> void:	
	ui_overlay.visible=false
	emit_signal("on_transaction_finish",get_transaction_id(transaction_byte_array))
	

func process_transaction_error() -> void:	
	ui_overlay.visible=false
	emit_signal("on_transaction_finish",null)
	
func pack_transfer_amount(amount_to_send:float)->PackedByteArray:
	var byte_array:PackedByteArray = PackedByteArray()
	#first 4 bytes for offset
	byte_array.append_array([2,0,0,0])
	#remaining 8 bytes for the amount to send
	var lamports_to_send = int(amount_to_send*1000000000)
	for i in range(8):
		byte_array.append(lamports_to_send%256)
		lamports_to_send = lamports_to_send/256
	
	return byte_array
