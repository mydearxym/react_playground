Meteor.publish 'fullUserData', (filter, limit) ->
	unless @userId
		return @ready()

	user = RocketChat.models.Users.findOneById @userId

	fields =
		name: 1
		username: 1
		status: 1
		utcOffset: 1

	if RocketChat.authz.hasPermission( @userId, 'view-full-other-user-info') is true
		fields = _.extend fields,
			emails: 1
			phone: 1
			statusConnection: 1
			createdAt: 1
			lastLogin: 1
			active: 1
			services: 1
			roles : 1
	else
		limit = 1

	filter = s.trim filter

	if not filter and limit is 1
		return @ready()

	options =
		fields: fields
		limit: limit
		sort: { username: 1 }

	console.log '[publish] fullUserData'.green, filter, limit

	if filter
		if limit is 1
			return RocketChat.models.Users.findByUsername filter, options
		else
			filterReg = new RegExp filter, "i"
			return RocketChat.models.Users.findByUsernameNameOrEmailAddress filterReg, options

	return RocketChat.models.Users.find {}, options
