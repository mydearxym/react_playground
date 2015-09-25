###
# Add a setting
# @param {String} _id
# @param {Mixed} value
# @param {Object} setting
###

RocketChat.settings.add = (_id, value, options = {}) ->
	if not _id or not value?
		return false

	# console.log '[functions] RocketChat.settings.add -> '.green, 'arguments:', arguments

	if Meteor.settings?[_id]?
		value = Meteor.settings[_id]

	updateSettings =
		i18nLabel: options.i18nLabel or _id
		i18nDescription: options.i18nDescription if options.i18nDescription?

	updateSettings.type = options.type if options.type
	updateSettings.multiline = options.multiline if options.multiline
	updateSettings.group = options.group if options.group
	updateSettings.section = options.section if options.section
	updateSettings.public = options.public if options.public

	return RocketChat.models.Settings.upsert { _id: _id }, { $setOnInsert: { value: value }, $set: updateSettings }

###
# Add a setting group
# @param {String} _id
###

RocketChat.settings.addGroup = (_id, options = {}) ->
	if not _id
		return false

	# console.log '[functions] RocketChat.settings.addGroup -> '.green, 'arguments:', arguments

	updateSettings =
		i18nLabel: options.i18nLabel or _id
		i18nDescription: options.i18nDescription if options.i18nDescription?
		type: 'group'

	return RocketChat.models.Settings.upsert { _id: _id }, { $set: updateSettings }


###
# Remove a setting by id
# @param {String} _id
###

RocketChat.settings.removeById = (_id) ->
	if not _id
		return false

	# console.log '[functions] RocketChat.settings.add -> '.green, 'arguments:', arguments

	return RocketChat.models.Settings.removeById _id


Meteor.methods
	saveSetting: (_id, value) ->
		console.log '[method] saveSetting', _id, value
		if Meteor.userId()?
			user = Meteor.users.findOne Meteor.userId()

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'edit-privileged-setting') is true
			throw new Meteor.Error 503, 'Not authorized'

		# console.log "saveSetting -> ".green, _id, value
		RocketChat.models.Settings.updateValueById _id, value
		return true
