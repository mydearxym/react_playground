Meteor.methods
	updateMessage: (message) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] updateMessage -> Invalid user")

		originalMessage = RocketChat.models.Messages.findOneById message._id

		hasPermission = RocketChat.authz.hasPermission(Meteor.userId(), 'edit-message', message.rid)
		editAllowed = RocketChat.settings.get 'Message_AllowEditing'
		editOwn = originalMessage?.u?._id is Meteor.userId()

		unless hasPermission or (editAllowed and editOwn)
			throw new Meteor.Error 'message-editing-not-allowed', "[methods] updateMessage -> Message editing not allowed"

		blockEditInMinutes = RocketChat.settings.get 'Message_AllowEditing_BlockEditInMinutes'
		if blockEditInMinutes? and blockEditInMinutes isnt 0
			msgTs = moment(originalMessage.ts) if originalMessage.ts?
			currentTsDiff = moment().diff(msgTs, 'minutes') if msgTs?
			if currentTsDiff > blockEditInMinutes
				throw new Meteor.Error 'message-editing-blocked'

		console.log '[methods] updateMessage -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		# If we keep history of edits, insert a new message to store history information
		if RocketChat.settings.get 'Message_KeepHistory'
			RocketChat.models.Messages.cloneAndSaveAsHistoryById originalMessage._id

		message.ets = new Date()

		if urls = message.msg.match /([A-Za-z]{3,9}):\/\/([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((\/[-\+=!:~%\/\.@\,\w]+)?\??([-\+=&!:;%@\/\.\,\w]+)?#?([\w]+)?)?/g
			message.urls = urls

		message = RocketChat.callbacks.run 'beforeSaveMessage', message

		tempid = message._id
		delete message._id

		RocketChat.models.Messages.update
			_id: tempid
		,
			$set: message

		# Meteor.defer ->
		# 	RocketChat.callbacks.run 'afterSaveMessage', RocketChat.models.Messages.findOneById(message.id)

