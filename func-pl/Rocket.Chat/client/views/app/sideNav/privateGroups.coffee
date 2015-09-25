Template.privateGroups.helpers
	tRoomMembers: ->
		return t('Members_placeholder')

	rooms: ->
		return ChatSubscription.find { t: { $in: ['p']}, f: { $ne: true }, open: true }, { sort: 't': 1, 'name': 1 }

	total: ->
		return ChatSubscription.find({ t: { $in: ['p']}, f: { $ne: true } }).count()

	totalOpen: ->
		return ChatSubscription.find({ t: { $in: ['p']}, f: { $ne: true }, open: true }).count()

	isActive: ->
		return 'active' if ChatSubscription.findOne({ t: { $in: ['p']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

Template.privateGroups.events
	'click .add-room': (e, instance) ->
		if RocketChat.authz.hasAtLeastOnePermission('create-p')
			SideNav.setFlex "privateGroupsFlex"
			SideNav.openFlex()
		else
			e.preventDefault()

	'click .more-groups': ->
		SideNav.setFlex "listPrivateGroupsFlex"
		SideNav.openFlex()
