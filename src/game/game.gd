extends Node2D

onready var connection_panel : PanelContainer = $CanvasLayer/ConnectionPanel
onready var host_field := $CanvasLayer/ConnectionPanel/GridContainer/HostField
onready var port_field := $CanvasLayer/ConnectionPanel/GridContainer/PortField
onready var message_label := $CanvasLayer/MessageLabel
onready var sync_lost_label := $CanvasLayer/SyncLostLabel

func _ready() -> void:
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
# warning-ignore:return_value_discarded
	SyncManager.connect("sync_started", self, "_on_sm_sync_started")
# warning-ignore:return_value_discarded
	SyncManager.connect("sync_stopped", self, "_on_sm_sync_stopped")
# warning-ignore:return_value_discarded
	SyncManager.connect("sync_lost", self, "_on_sm_sync_lost")
# warning-ignore:return_value_discarded
	SyncManager.connect("sync_regained", self, "_on_sm_sync_regained")
# warning-ignore:return_value_discarded
	SyncManager.connect("sync_error", self, "_on_sm_sync_error")

func _on_ServerButton_pressed() -> void:
	var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
# warning-ignore:return_value_discarded
	peer.create_server(int(port_field.text), 1)
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = "Listening..."

func _on_ClientButton_pressed() -> void:
	var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
# warning-ignore:return_value_discarded
	peer.create_client(host_field.text, int(port_field.text))
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = "Connecting..."

func _on_network_peer_connected(peer_id: int) -> void:
	message_label.text = "Connected!"
	SyncManager.add_peer(peer_id)
	
	$ServerPlayer.set_network_master(1)
	if get_tree().is_network_server(): $ClientPlayer.set_network_master(peer_id)
	else: $ClientPlayer.set_network_master(get_tree().get_network_unique_id())
	
	if get_tree().is_network_server():
		message_label.text = "Starting..."
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()

func _on_network_peer_disconnected(peer_id: int) -> void:
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)

func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer : NetworkedMultiplayerENet = get_tree().network_peer
	if peer: peer.close_connection()
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _on_sm_sync_started() -> void:
	message_label.text = "Started!"

func _on_sm_sync_stopped() -> void:
	pass

func _on_sm_sync_lost() -> void:
	sync_lost_label.visible = true

func _on_sm_sync_regained() -> void:
	sync_lost_label.visible = false

func _on_sm_sync_error(msg: String) -> void:
	message_label.text = "Fatal sync error: " + msg
	sync_lost_label.visible = false
	
	var peer : NetworkedMultiplayerENet = get_tree().network_peer
	if peer: peer.close_connection()
	SyncManager.clear_peers()
