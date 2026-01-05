extends Node
class_name C_UserVoice

var peer_id: int = -1

static func create(peer: int) -> C_UserVoice:
	var voice := C_UserVoice.new()
	voice.peer_id = peer
	return voice
