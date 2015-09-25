RocketChat.models.Subscriptions = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'subscription'

		@tryEnsureIndex { 'rid': 1, 'u._id': 1 }, { unique: 1 }
		@tryEnsureIndex { 'u._id': 1, 'name': 1, 't': 1 }, { unique: 1 }
		@tryEnsureIndex { 'open': 1 }
		@tryEnsureIndex { 'alert': 1 }
		@tryEnsureIndex { 'unread': 1 }
		@tryEnsureIndex { 'ts': 1 }


	# FIND ONE
	findOneByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			"u._id": userId

		return @findOne query

	# FIND
	findByUserId: (userId, options) ->
		query =
			"u._id": userId

		return @find query, options


	# UPDATE
	archiveByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			'u._id': userId

		update =
			$set:
				alert: false
				open: false
				archived: true

		return @update query, update

	unarchiveByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			'u._id': userId

		update =
			$set:
				alert: false
				open: false
				archived: false

		return @update query, update

	hideByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			'u._id': userId

		update =
			$set:
				alert: false
				open: false

		return @update query, update

	openByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			'u._id': userId

		update =
			$set:
				open: true

		return @update query, update

	setAsReadByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			'u._id': userId

		update =
			$set:
				open: true
				alert: false
				unread: 0
				ls: new Date

		return @update query, update

	setFavoriteByRoomIdAndUserId: (roomId, userId, favorite=true) ->
		query =
			rid: roomId
			'u._id': userId

		update =
			$set:
				f: favorite

		return @update query, update

	updateNameByRoomId: (roomId, name) ->
		query =
			rid: roomId

		update =
			$set:
				name: name
				alert: true

		return @update query, update, { multi: true }

	setUserUsernameByUserId: (userId, username) ->
		query =
			"u._id": userId

		update =
			$set:
				"u.username": username

		return @update query, update, { multi: true }

	setNameForDirectRoomsWithOldName: (oldName, name) ->
		query =
			name: oldName
			t: "d"

		update =
			$set:
				name: name

		return @update query, update, { multi: true }

	incUnreadOfDirectForRoomIdExcludingUserId: (roomId, userId, inc=1) ->
		query =
			rid: roomId
			t: 'd'
			'u._id':
				$ne: userId

		update =
			$set:
				alert: true
				open: true
			$inc:
				unread: inc

		return @update query, update, { multi: true }

	incUnreadForRoomIdExcludingUserId: (roomId, userId, inc=1) ->
		query =
			rid: roomId
			'u._id':
				$ne: userId

		update =
			$set:
				alert: true
				open: true
			$inc:
				unread: inc

		return @update query, update, { multi: true }

	incUnreadForRoomIdAndUserIds: (roomId, userIds, inc=1) ->
		query =
			rid: roomId
			'u._id':
				$in: userIds

		update =
			$set:
				alert: true
				open: true
			$inc:
				unread: inc

		return @update query, update, { multi: true }

	setAlertForRoomIdExcludingUserId: (roomId, userId, alert=true) ->
		query =
			rid: roomId
			alert:
				$ne: alert
			'u._id':
				$ne: userId

		update =
			$set:
				alert: alert
				open: true

		return @update query, update, { multi: true }


	# INSERT
	createWithRoomAndUser: (room, user, extraData) ->
		subscription =
			open: false
			alert: false
			unread: 0
			ts: room.ts
			rid: room._id
			name: room.name
			t: room.t
			u:
				_id: user._id
				username: user.username

		_.extend subscription, extraData

		return @insert subscription


	# REMOVE
	removeByUserId: (userId) ->
		query =
			"u._id": userId

		return @remove query

	removeByRoomId: (roomId) ->
		query =
			rid: roomId

		return @remove query

	removeByRoomIdAndUserId: (roomId, userId) ->
		query =
			rid: roomId
			"u._id": userId

		return @remove query
