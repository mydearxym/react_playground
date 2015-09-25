RocketChat.models.Rooms = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'room'

		@tryEnsureIndex { 'name': 1 }, { unique: 1, sparse: 1 }
		@tryEnsureIndex { 'u._id': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByName: (name, options) ->
		query =
			name: name

		return @findOne query, options

	findOneByNameAndType: (name, type, options) ->
		query =
			name: name
			t: type

		return @findOne query, options

	findOneByIdContainigUsername: (_id, username, options) ->
		query =
			_id: _id
			usernames: username

		return @findOne query, options

	findOneByNameAndTypeNotContainigUsername: (name, type, username, options) ->
		query =
			name: name
			t: type
			usernames:
				$ne: username

		return @findOne query, options


	# FIND
	findByType: (type, options) ->
		query =
			t: type

		return @find query, options

	findByTypes: (types, options) ->
		query =
			t:
				$in: types

		return @find query, options

	findByUserId: (userId, options) ->
		query =
			"u._id": userId

		return @find query, options

	findByNameContaining: (name, options) ->
		nameRegex = new RegExp name, "i"

		query =
			$or: [
				name: nameRegex
			,
				t: 'd'
				usernames: nameRegex
			]

		return @find query, options

	findByNameContainingAndTypes: (name, types, options) ->
		nameRegex = new RegExp name, "i"

		query =
			t:
				$in: types
			$or: [
				name: nameRegex
			,
				t: 'd'
				usernames: nameRegex
			]

		return @find query, options

	findByDefaultAndTypes: (defaultValue, types, options) ->
		query =
			default: defaultValue
			t:
				$in: types

		return @find query, options

	findByTypeContainigUsername: (type, username, options) ->
		query =
			t: type
			usernames: username

		return @find query, options

	findByTypesAndNotUserIdContainingUsername: (types, userId, username, options) ->
		query =
			t:
				$in: types
			uid:
				$ne: userId
			usernames: username

		return @find query, options

	findByContainigUsername: (username, options) ->
		query =
			usernames: username

		return @find query, options

	findByTypeAndName: (type, name, options) ->
		query =
			t: type
			name: name

		return @find query, options

	findByTypeAndNameContainigUsername: (type, name, username, options) ->
		query =
			t: type
			name: name
			usernames: username

		return @find query, options

	findByVisitorToken: (visitorToken, options) ->
		query =
			"v.token": visitorToken

		return @find query, options


	# UPDATE
	archiveById: (_id) ->
		query =
			_id: _id

		update =
			$set:
				archived: true

		return @update query, update

	unarchiveById: (_id) ->
		query =
			_id: _id

		update =
			$set:
				archived: false

		return @update query, update

	addUsernameById: (_id, username) ->
		query =
			_id: _id

		update =
			$addToSet:
				usernames: username

		return @update query, update

	addUsernamesById: (_id, usernames) ->
		query =
			_id: _id

		update =
			$addToSet:
				usernames:
					$each: usernames

		return @update query, update

	addUsernameByName: (name, username) ->
		query =
			name: name

		update =
			$addToSet:
				usernames: username

		return @update query, update

	removeUsernameById: (_id, username) ->
		query =
			_id: _id

		update =
			$pull:
				usernames: username

		return @update query, update

	removeUsernamesById: (_id, usernames) ->
		query =
			_id: _id

		update =
			$pull:
				usernames:
					$in: usernames

		return @update query, update

	removeUsernameFromAll: (username) ->
		query = {}

		update =
			$pull:
				usernames: username

		return @update query, update, { multi: true }

	removeUsernameByName: (name, username) ->
		query =
			name: name

		update =
			$pull:
				usernames: username

		return @update query, update

	setNameById: (_id, name) ->
		query =
			_id: _id

		update =
			$set:
				name: name

		return @update query, update

	incUnreadAndSetLastMessageTimestampById: (_id, inc=1, lastMessageTimestamp) ->
		query =
			_id: _id

		update =
			$set:
				lm: lastMessageTimestamp
			$inc:
				msgs: inc

		return @update query, update

	replaceUsername: (previousUsername, username) ->
		query =
			usernames: previousUsername

		update =
			$set:
				"usernames.$": username

		return @update query, update, { multi: true }

	replaceUsernameOfUserByUserId: (userId, username) ->
		query =
			"u._id": userId

		update =
			$set:
				"u.username": username

		return @update query, update, { multi: true }

	setUserById: (_id, user) ->
		query =
			_id: _id

		update =
			$set:
				u:
					_id: user._id
					username: user.username

		return @update query, update


	# INSERT
	createWithTypeNameUserAndUsernames: (type, name, user, usernames, extraData) ->
		room =
			t: type
			name: name
			usernames: usernames
			msgs: 0
			u:
				_id: user._id
				username: user.username

		_.extend room, extraData

		room._id = @insert room
		return room

	createWithIdTypeAndName: (_id, type, name, extraData) ->
		room =
			_id: _id
			ts: new Date()
			t: type
			name: name
			usernames: []
			msgs: 0

		_.extend room, extraData

		@insert room
		return room


	# REMOVE
	removeById: (_id) ->
		query =
			_id: _id

		return @remove query

	removeByTypeContainingUsername: (type, username) ->
		query =
			t: type
			username: username

		return @remove query
