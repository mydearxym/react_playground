RocketChat.sendMessage = (user, message, room, options) ->

	if not user or not message or not room._id
		return false

	unless message.ts?
		message.ts = new Date()

	message.u = _.pick user, ['_id','username']

	message.rid = room._id

	if urls = message.msg.match /([A-Za-z]{3,9}):\/\/([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((\/[-\+=!:~%\/\.@\,\w]+)?\??([-\+=&!:;%@\/\.\,\w]+)?#?([\w]+)?)?/g
		message.urls = urls.map (url) -> url: url

	message = RocketChat.callbacks.run 'beforeSaveMessage', message

	if message._id? and options?.upsert is true
		RocketChat.models.Messages.upsert {_id: message._id}, message
	else
		message._id = RocketChat.models.Messages.insert message

	###
	Defer other updates as their return is not interesting to the user
	###

	###
	Execute all callbacks
	###
	Meteor.defer ->

		RocketChat.callbacks.run 'afterSaveMessage', message

	###
	Update all the room activity tracker fields
	###
	Meteor.defer ->
		RocketChat.models.Rooms.incUnreadAndSetLastMessageTimestampById message.rid, 1, message.ts

	###
	Increment unread couter if direct messages
	###
	Meteor.defer ->

		if not room.t? or room.t is 'd'

			###
			Update the other subscriptions
			###
			RocketChat.models.Subscriptions.incUnreadOfDirectForRoomIdExcludingUserId message.rid, message.u._id, 1

			userOfMention = Meteor.users.findOne({_id: message.rid.replace(message.u._id, '')}, {fields: {username: 1, statusConnection: 1}})
			if userOfMention?
				RocketChat.Notifications.notifyUser userOfMention._id, 'notification',
					title: "@#{user.username}"
					text: message.msg
					payload:
						rid: message.rid
						sender: message.u
						type: room.t
						name: room.name

				if Push.enabled is true and userOfMention.statusConnection isnt 'online'
					Push.send
						from: 'push'
						title: "@#{user.username}"
						text: message.msg
						apn:
							text: "@#{user.username}:\n#{message.msg}"
						badge: 1
						sound: 'chime'
						payload:
							rid: message.rid
							sender: message.u
							type: room.t
							name: room.name
						query:
							userId: userOfMention._id

		else
			mentionIds = []
			message.mentions?.forEach (mention) ->
				mentionIds.push mention._id

			if mentionIds.length > 0
				usersOfMention = Meteor.users.find({_id: {$in: mentionIds}}, {fields: {_id: 1, username: 1}}).fetch()

				if room.t is 'c' and mentionIds.indexOf('all') is -1
					for usersOfMentionItem in usersOfMention
						if room.usernames.indexOf(usersOfMentionItem.username) is -1
							Meteor.runAsUser usersOfMentionItem._id, ->
								Meteor.call 'joinRoom', room._id

				###
				Update all other subscriptions of mentioned users to alert their owners and incrementing
				the unread counter for mentions and direct messages
				###
				if mentionIds.indexOf('all') > -1
					# all users except sender if mention is for all
					RocketChat.models.Subscriptions.incUnreadForRoomIdExcludingUserId message.rid, user._id, 1
				else
					# the mentioned user if mention isn't for all
					RocketChat.models.Subscriptions.incUnreadForRoomIdAndUserIds message.rid, mentionIds, 1

				query =
					statusConnection: {$ne: 'online'}

				if mentionIds.indexOf('all') > -1
					if room.usernames?.length > 0
						query.username =
							$in: room.usernames
					else
						query.username =
							$in: []
				else
					query._id =
						$in: mentionIds

				usersOfMentionIds = _.pluck(usersOfMention, '_id');
				if usersOfMentionIds.length > 0
					for usersOfMentionId in usersOfMentionIds
						RocketChat.Notifications.notifyUser usersOfMentionId, 'notification',
							title: "@#{user.username} @ ##{room.name}"
							text: message.msg
							payload:
								rid: message.rid
								sender: message.u
								type: room.t
								name: room.name

					if Push.enabled is true
						Push.send
							from: 'push'
							title: "@#{user.username} @ ##{room.name}"
							text: message.msg
							apn:
								text: "@#{user.username} @ ##{room.name}:\n#{message.msg}"
							badge: 1
							sound: 'chime'
							payload:
								rid: message.rid
								sender: message.u
								type: room.t
								name: room.name
							query:
								userId: $in: usersOfMentionIds

		###
		Update all other subscriptions to alert their owners but witout incrementing
		the unread counter, as it is only for mentions and direct messages
		###
		RocketChat.models.Subscriptions.setAlertForRoomIdExcludingUserId message.rid, message.u._id, true

	return message
