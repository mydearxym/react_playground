Meteor.startup ->

	ChatSubscription.find({}, { fields: { unread: 1 } }).observeChanges
		changed: (id, fields) ->
			if fields.unread and fields.unread > 0
				KonchatNotification.newMessage()

Meteor.startup ->

	Tracker.autorun ->

		unreadCount = 0
		unreadAlert = false

		subscriptions = ChatSubscription.find({open: true}, { fields: { unread: 1, alert: 1, rid: 1, t: 1, name: 1, ls: 1 } })

		rid = undefined
		Tracker.nonreactive ->
			if FlowRouter.getRouteName() in ['channel', 'group', 'direct']
				rid = Session.get 'openedRoom'

		for subscription in subscriptions.fetch()
			if subscription.rid is rid and (subscription.alert or subscription.unread > 0)
				readMessage.readNow()
			else
				unreadCount += subscription.unread
				if subscription.alert is true
					unreadAlert = '•'

			readMessage.refreshUnreadMark(subscription.rid)

		menu.updateUnreadBars()

		if unreadCount > 0
			if unreadCount > 999
				Session.set 'unread', '999+'
			else
				Session.set 'unread', unreadCount
		else if unreadAlert isnt false
			Session.set 'unread', unreadAlert
		else
			Session.set 'unread', ''

Meteor.startup ->

	window.favico = new Favico
		position: 'up'
		animation: 'none'

	Tracker.autorun ->
		siteName = RocketChat.settings.get 'Site_Name'

		unread = Session.get 'unread'
		fireGlobalEvent 'unread-changed', unread
		favico?.badge unread, bgColor: if typeof unread isnt 'number' then '#3d8a3a' else '#ac1b1b'
		document.title = if unread == '' then siteName else '(' + unread + ') '+ siteName
