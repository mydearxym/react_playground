Meteor.methods
	leaveRoom: (rid) ->
		fromId = Meteor.userId()
		# console.log '[methods] leaveRoom -> '.green, 'fromId:', fromId, 'rid:', rid

		unless Meteor.userId()?
			throw new Meteor.Error 300, 'Usuário não logado'

		room = RocketChat.models.Rooms.findOneById rid
		user = Meteor.user()

		RocketChat.callbacks.run 'beforeLeaveRoom', user, room

		RocketChat.models.Rooms.removeUsernameById rid, user.username

		if room.t isnt 'c' and room.usernames.indexOf(user.username) isnt -1
			removedUser = user

			RocketChat.models.Messages.createUserJoinWithRoomIdAndUser rid, removedUser

		if room.u?._id is Meteor.userId()
			newOwner = _.without(room.usernames, user.username)[0]
			if newOwner?
				newOwner = RocketChat.models.Users.findOneByUsername newOwner

				if newOwner?
					RocketChat.models.Rooms.setUserById rid, newOwner

		RocketChat.models.Subscriptions.removeByRoomIdAndUserId rid, Meteor.userId()

		Meteor.defer ->

			RocketChat.callbacks.run 'afterLeaveRoom', user, room
