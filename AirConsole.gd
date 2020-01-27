extends Node

const SCREEN = 0
const ORIENTATION_PORTRAIT = 'portrait'
const ORIENTATION_LANDSCAPE = 'landscape'

const PARSE_JS = true

export(bool) var print_signal = false

signal device_connected(device_id)
signal device_disconnected(device_id)
signal is_ready(join_code)
signal message_received(device_id, data)
signal custom_device_state_changed(device_id, custom_data)
signal device_state_changed(device_id, user_data)
signal device_profile_changed(device_id)
signal email_address(email_address)
signal active_players_changed(player_number)
signal device_motion(data)
signal ad_completed(ad_was_shown)
signal ad_shown()
signal premium(device_id)
signal persistent_data_loaded(data)
signal persistent_data_stored(uid)
signal highscores(highscores)
signal highscores_stored(highscore)

func get_controller_device_ids() -> Array:
	return js('airconsole.getControllerDeviceIds()', PARSE_JS)

func get_device_id() -> int:
	return js('airconsole.getDeviceId()')

func get_master_controller_device_id() -> int:
	return js('airconsole.getMasterControllerDeviceId()')

func get_server_time() -> int:
	return js('airconsole.getServerTime()')

func broadcast(data):
	js('airconsole.broadcast(%s)' % to_json(data))

func message(device_id:int, data):
	js('airconsole.message(%s, %s)' % [device_id, to_json(data)])

func get_custom_device_state(device_id):
	return js('airconsole.getCustomDeviceState(%s)' % device_id, PARSE_JS)

func set_custom_device_state(data):
	js('airconsole.setCustomDeviceState(%s)' % to_json(data))

func set_custom_device_state_property(key:String, value):
	js('airconsole.setCustomDeviceStateProperty(%s, %s)' % [to_json(key), to_json(value)])

func edit_profile():
	js('airconsole.editProfile()')

func get_nickname(device_id:int) -> String:
	return js('airconsole.getNickname(%s)' % device_id)

func get_profile_picture(device_id_or_uid, size = 64) -> String:
	return js('airconsole.getProfilePicture(%s, %s)' % [to_json(device_id_or_uid), size])

func get_uid(device_id:int = get_device_id()) -> String:
	return js('airconsole.getUID(%s)' % to_json(device_id))

func is_user_logged_in(device_id:int) -> bool:
	return js('airconsole.isUserLoggedIn(%s)' % device_id)

func request_email_address():
	js('airconsole.requestEmailAddress()')

func convert_device_id_to_player_number(device_id:int) -> int:
	return js('airconsole.convertDeviceIdToPlayerNumber(%s)' % device_id)

func convert_player_number_to_device_id(player_number:int) -> int:
	return js('airconsole.convertPlayerNumberToDeviceId(%s)' % player_number)

func get_active_player_device_ids() -> Array:
	return js('airconsole.getActivePlayerDeviceIds()', PARSE_JS)

func set_active_players(max_players:int):
	js('airconsole.setActivePlayers(%s)' % max_players)

func vibrate(miliseconds:int):
	js('airconsole.vibrate(%s)' % miliseconds)

func show_ad():
	js('airconsole.showAd()')

func get_premium():
	js('airconsole.getPremium()')

func get_premium_device_ids() -> Array:
	return js('airconsole.getPremiumDeviceIds()', PARSE_JS)

func is_premium(device_id:int) -> bool:
	return js('airconsole.isPremium(%s)' % device_id)

func get_navigate_parameters():
	return js('airconsole.getNavigateParameters()', PARSE_JS)

func navigate_home():
	js('airconsole.navigateHome()')

func navigate_to(url:String, parameters):
	js('airconsole.navigate_to(%s, %s)' % [to_json(url), to_json(parameters)])

func open_external_url(url:String):
	js('airconsole.openExternalUrl(%s)' % to_json(url))

func set_orientation(orientation:String):
	js('airconsole.setOrientation(%s)' % to_json(orientation))

func show_default_ui(visible:bool):
	js('airconsole.showDefaultUI(%s)' % visible)

func request_persistent_data(uids:Array = []):
	js('airconsole.requestPersistentData(%s)' % to_json(uids))

func store_persistent_data(key:String, value, uid:String = get_uid()):
	js('airconsole.storePersistentData(%s, %s, %s)' % [to_json(key), to_json(value), to_json(uid)])

func request_highscores(level_name:String, level_version:String, uids:PoolStringArray, ranks:PoolStringArray, total:int = 8, top:int = 5):
	js('airconsole.requestHighScores(%s, %s, %s, %s, %s, %s)' % [to_json(level_name), to_json(level_version), to_json(uids), to_json(ranks), total, top])

func store_highscore(level_name:String, level_version:String, score:int, uid:String, data, score_string:String):
	js('airconsole.storeHighScore(%s, %s, %s, %s, %s, %s)' % [to_json(level_name), to_json(level_version), score, to_json(uid), to_json(data), to_json(score_string)])

func _ready():
	_setup_signals()
	
	if print_signal:
		print_debug('GodotAirConsole initialized.')

func _init():
	js("airconsole = new AirConsole({ synchronize_time:true })")
	js("signals = {}")
	
	js("""
		function has_signals() {
			return Object.keys(signals).length > 0
		}

		function get_signals() {
			var string = JSON.stringify(signals)
			signals = {}
			return string
		}
	""")

func _setup_signals():
	_setup_signal('onConnect', 'device_connected', ['device_id'])
	_setup_signal('onDisconnect', 'device_disconnected', ['device_id'])
	_setup_signal('onReady', 'is_ready', ['join_code'])
	_setup_signal('onMessage', 'message_received', ['device_id', 'data'])
	_setup_signal('onCustomDeviceStateChange', 'custom_device_state_changed', ['device_id', 'custom_data'])
	_setup_signal('onDeviceStateChange', 'device_state_changed', ['device_id', 'user_data'])
	_setup_signal('onDeviceProfileChange', 'device_profile_changed', ['device_id'])
	
	_setup_signal('onEmailAddress', 'email_address', ['email_address'])
	_setup_signal('onActivePlayersChange', 'active_players_changed', ['player_number'])
	_setup_signal('onDeviceMotion', 'device_motion', ['data'])
	_setup_signal('onAdComplete', 'ad_completed', ['ad_was_shown'])
	_setup_signal('onAdShow', 'ad_shown', [])
	_setup_signal('onPremium', 'premium', ['device_id'])
	_setup_signal('onPersistentDataLoaded', 'persistent_data_loaded', ['data'])
	_setup_signal('onPersistentDataStored', 'persistent_data_stored', ['uid'])
	_setup_signal('onHighScores', 'highscores', ['highscores'])
	_setup_signal('onHighScoreStored', 'highscores_stored', ['highscore'])

func _setup_signal(airconsoleMethod:String, signalName:String, parameters:PoolStringArray):
	var parameters_string = parameters.join(',')
	var template = \
	"""airconsole.{airconsole} = function({parameters}) {
		signals['{signal}'] = [{parameters}]
	}"""
	var code = template.format({
		'airconsole': airconsoleMethod,
		'signal': signalName,
		'parameters': parameters_string
	})
	js(code)

func js(code:String, parse_js = false):
	if parse_js:
		code = 'JSON.stringify(%s)' % code
	
	var value = JavaScript.eval(code, true)
	
	if parse_js:
		value = parse_json(value)
	return value

func _physics_process(delta):
	_poll_signals()

func _poll_signals():
	if not js('has_signals()'): return
	
	var signals = parse_json(js('get_signals()'))
	for s in signals:
		var arguments = signals[s].duplicate()
		if print_signal:
			print_debug('GodotAirConsole: Signal %s(%s)' % [s, _to_argument_string(arguments)])
		arguments.push_front(s)
		callv('emit_signal', arguments)

func _to_argument_string(array:Array):
	return str(array).replace('[', '').replace(']', '')