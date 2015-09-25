Meteor.methods
	addUserToRoom: (data) ->
		fromId = Meteor.userId()
		console.log '[methods] addUserToRoom -> '.green, 'data:', data

		unless Match.test data?.rid, String
			throw new Meteor.Error 'invalid-rid'

		unless Match.test data?.username, String
			throw new Meteor.Error 'invalid-username'

		room = RocketChat.models.Rooms.findOneById data.rid

		# if room.username isnt Meteor.user().username and room.t is 'c'
		if room.t is 'c' and room.u?.username isnt Meteor.user().username
			throw new Meteor.Error 403, '[methods] addUserToRoom -> Not allowed'

		# verify if user is already in room
		if room.usernames.indexOf(data.username) isnt -1
			return

		newUser = RocketChat.models.Users.findOneByUsername data.username

		RocketChat.models.Rooms.addUsernameById data.rid, data.username

		now = new Date()

		RocketChat.models.Subscriptions.createWithRoomAndUser room, newUser,
			ts: now
			open: true
			alert: true
			unread: 1

		RocketChat.models.Messages.createUserAddedWithRoomIdAndUser data.rid, newUser,
			ts: now

		return true
