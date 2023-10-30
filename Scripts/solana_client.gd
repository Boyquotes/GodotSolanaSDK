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
		SolanaSDK.set_url(custom_rpc)
		
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
	
func send_transaction(receiver:String,amount:float) -> void:
	ui_overlay.visible=true
	var transaction:Transaction = Transaction.new()
	transaction.update_latest_blockhash(SolanaSDK.get_latest_blockhash())
	
func process_transaction_pass(transaction_id:PackedByteArray) -> void:	
	emit_signal("on_transaction_finish",transaction_id)

func process_transaction_error() -> void:	
	emit_signal("on_transaction_finish",null)
