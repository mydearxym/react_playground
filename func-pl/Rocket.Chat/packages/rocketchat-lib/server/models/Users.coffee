RocketChat.models.Users = new class extends RocketChat.models._Base
	constructor: ->
		@model = Meteor.users


	# FIND ONE
	findOneById: (_id, options) ->
		return @findOne _id, options

	findOneByUsername: (username, options) ->
		query =
			username: username

		return @findOne query, options

	findOneByEmailAddress: (emailAddress, options) ->
		query =
			'email.address': emailAddress

		return @findOne query, options

	findOneByVerifiedEmailAddress: (emailAddress, verified=true, options) ->
		query =
			emails:
				$elemMatch:
					address: emailAddress
					verified: verified

		return @findOne query, options

	findOneAdmin: (admin, options) ->
		query =
			admin: admin

		return @findOne query, options


	# FIND
	findUsersNotOffline: (options) ->
		query =
			username:
				$exists: 1
			status:
				$in: ['online', 'away', 'busy']

		return @find query, options


	findByUsername: (username, options) ->
		query =
			username: username

		return @find query, options

	findUsersByNameOrUsername: (nameOrUsername, options) ->
		query =
			username:
				$exists: 1

			$or: [
				{name: nameOrUsername}
				{username: nameOrUsername}
			]

		return @find query, options

	findByUsernameNameOrEmailAddress: (usernameNameOrEmailAddress, options) ->
		query =
			$or: [
				{name: usernameNameOrEmailAddress}
				{username: usernameNameOrEmailAddress}
				{'emails.address': usernameNameOrEmailAddress}
			]

		return @find query, options


	# UPDATE
	updateLastLoginById: (_id) ->
		update =
			$set:
				lastLogin: new Date

		return @update _id, update

	setServiceId: (_id, serviceName, serviceId) ->
		update =
			$set: {}

		serviceIdKey = "services.#{serviceName}.id"
		update.$set[serviceIdKey] = serviceId

		return @update _id, update

	setUsername: (_id, username) ->
		update =
			$set: username: username

		return @update _id, update

	setName: (_id, name) ->
		update =
			$set:
				name: name

		return @update _id, update

	setAvatarOrigin: (_id, origin) ->
		update =
			$set:
				avatarOrigin: origin

		return @update _id, update

	unsetAvatarOrigin: (_id) ->
		update =
			$unset:
				avatarOrigin: 1

		return @update _id, update

	setUserActive: (_id, active=true) ->
		update =
			$set:
				active: active

		return @update _id, update

	setAllUsersActive: (active) ->
		update =
			$set:
				active: active

		return @update {}, update, { multi: true }

	unsetLoginTokens: (_id) ->
		update =
			$set:
				"services.resume.loginTokens" : []

		return @update _id, update

	setLanguage: (_id, language) ->
		update =
			$set:
				language: language

		return @update _id, update

	setProfile: (_id, profile) ->
		update =
			$set:
				"settings.profile": profile

		return @update _id, update

	setPreferences: (_id, preferences) ->
		update =
			$set:
				"settings.preferences": preferences

		return @update _id, update

	setUtcOffset: (_id, utcOffset) ->
		query =
			_id: _id
			utcOffset:
				$ne: utcOffset

		update =
			$set:
				utcOffset: utcOffset

		return @update query, update


	# INSERT
	create: (data) ->
		user =
			createdAt: new Date
			avatarOrigin: 'none'

		_.extend user, data

		return @insert user


	# REMOVE
	removeById: (_id) ->
		return @remove _id

	removeByUnverifiedEmail: (email) ->
		query =
			emails:
				$elemMatch:
					address: email
					verified: false

		return @remove query
