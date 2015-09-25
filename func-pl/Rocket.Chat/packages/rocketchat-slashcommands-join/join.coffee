###
# Join is a named function that will replace /join commands
# @param {Object} message - The message object
###

if Meteor.isClient
	RocketChat.slashCommands.add 'join', undefined,
		description: 'Join the given channel'
		params: '#channel'
else
	class Join
		constructor: (command, params) ->
			if command isnt 'join' or not Match.test params, String
				return

			channel = params.trim()
			if channel is ''
				return

			channel = channel.replace('#', '')

			user = Meteor.users.findOne Meteor.userId()
			room = RocketChat.models.Rooms.findOneByNameAndTypeNotContainigUsername(channel, 'c', user.username)

			if not room?
				return

			Meteor.call 'joinRoom', room._id

	RocketChat.slashCommands.add 'join', Join
