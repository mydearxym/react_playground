Meteor.publish 'userData', ->
	unless this.userId
		return this.ready()

	console.log '[publish] userData'.green

	RocketChat.models.Users.find this.userId,
		fields:
			name: 1
			username: 1
			status: 1
			statusDefault: 1
			statusConnection: 1
			avatarOrigin: 1
			utcOffset: 1
			language: 1
			settings: 1
			defaultRoom: 1
