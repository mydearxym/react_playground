RocketChat.statistics.get = ->
	statistics = {}

	# Version
	statistics.uniqueId = RocketChat.settings.get("uniqueID")
	statistics.version = BuildInfo?.commit?.hash
	statistics.versionDate = BuildInfo?.commit?.date

	# User statistics
	statistics.totalUsers = Meteor.users.find().count()
	statistics.activeUsers = Meteor.users.find({ active: true }).count()
	statistics.nonActiveUsers = statistics.totalUsers - statistics.activeUsers
	statistics.onlineUsers = Meteor.users.find({ statusConnection: 'online' }).count()
	statistics.awayUsers = Meteor.users.find({ statusConnection: 'away' }).count()
	statistics.offlineUsers = statistics.totalUsers - statistics.onlineUsers - statistics.awayUsers

	# Room statistics
	statistics.totalRooms = RocketChat.models.Rooms.find().count()
	statistics.totalChannels = RocketChat.models.Rooms.findByType('c').count()
	statistics.totalPrivateGroups = RocketChat.models.Rooms.findByType('p').count()
	statistics.totalDirect = RocketChat.models.Rooms.findByType('d').count()

	# Message statistics
	statistics.totalMessages = RocketChat.models.Messages.find().count()

	m = ->
		emit 1,
			sum: this.usernames.length or 0
			min: this.usernames.length or 0
			max: this.usernames.length or 0
			count: 1

		emit this.t,
			sum: this.usernames.length or 0
			min: this.usernames.length or 0
			max: this.usernames.length or 0
			count: 1

	r = (k, v) ->
		a = v.shift()
		for b in v
			a.sum += b.sum
			a.min = Math.min a.min, b.min
			a.max = Math.max a.max, b.max
			a.count += b.count
		return a

	f = (k, v) ->
		v.avg = v.sum / v.count
		return v

	result = RocketChat.models.Rooms.model.mapReduce(m, r, { finalize: f, out: "rocketchat_mr_statistics" })

	statistics.maxRoomUsers = 0
	statistics.avgChannelUsers = 0
	statistics.avgPrivateGroupUsers = 0

	if RocketChat.models.MRStatistics.findOneById(1)
		statistics.maxRoomUsers = RocketChat.models.MRStatistics.findOneById(1).value.max
	else
		console.log 'max room user statistic not found'.red

	if RocketChat.models.MRStatistics.findOneById('c')
		statistics.avgChannelUsers = RocketChat.models.MRStatistics.findOneById('c').value.avg
	else
		console.log 'channel user statistic not found'.red

	if RocketChat.models.MRStatistics.findOneById('p')
		statistics.avgPrivateGroupUsers = RocketChat.models.MRStatistics.findOneById('p').value.avg
	else
		console.log 'private group user statistic not found'.red

	os = Npm.require('os')
	statistics.os =
		type: os.type()
		platform: os.platform()
		arch: os.arch()
		release: os.release()
		uptime: os.uptime()
		loadavg: os.loadavg()
		totalmem: os.totalmem()
		freemem: os.freemem()
		cpus: os.cpus()

	return statistics
