Template.adminUsers.helpers
	isReady: ->
		return Template.instance().ready?.get()
	users: ->
		return Template.instance().users()
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	arrowPosition: ->
		return 'left' unless RocketChat.TabBar.isFlexOpen()
	userData: ->
		return Meteor.users.findOne Session.get 'adminSelectedUser'
	userChannels: ->
		return ChatSubscription.find({ "u._id": Session.get 'adminSelectedUser' }, { fields: { rid: 1, name: 1, t: 1 }, sort: { t: 1, name: 1 } }).fetch()
	isLoading: ->
		return 'btn-loading' unless Template.instance().ready?.get()
	hasMore: ->
		return Template.instance().limit?.get() is Template.instance().users?().length

	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()

	flexData: ->
		return RocketChat.TabBar.getData()

	adminClass: ->
		return 'admin' if RocketChat.authz.hasRole(Meteor.userId(), 'admin')

Template.adminUsers.onCreated ->
	instance = @
	@limit = new ReactiveVar 50
	@filter = new ReactiveVar ''
	@ready = new ReactiveVar true

	RocketChat.TabBar.addButton({ id: 'invite-user', title: t('Invite_Users'), icon: 'icon-plus', template: 'adminInviteUser', order: 1 })

	@autorun ->
		filter = instance.filter.get()
		limit = instance.limit.get()
		subscription = instance.subscribe 'fullUserData', filter, limit
		instance.ready.set subscription.ready()

	@autorun ->
		if Session.get 'adminSelectedUser'
			channelSubscription = instance.subscribe 'userChannels', Session.get 'adminSelectedUser'
			RocketChat.TabBar.setData Meteor.users.findOne Session.get 'adminSelectedUser'
			RocketChat.TabBar.addButton({ id: 'user-info', title: t('User_Info'), icon: 'icon-user', template: 'adminUserInfo', order: 2 })
			# RocketChat.TabBar.addButton({ id: 'user-channel', title: t('User_Channels'), icon: 'icon-hash', template: 'adminUserChannels', order: 3 })
		else
			RocketChat.TabBar.reset()
			RocketChat.TabBar.addButton({ id: 'invite-user', title: t('Invite_Users'), icon: 'icon-plus', template: 'adminInviteUser', order: 1 })

	@users = ->
		filter = _.trim instance.filter?.get()
		if filter
			filterReg = new RegExp filter, "i"
			query = { $or: [ { username: filterReg }, { name: filterReg }, { "emails.address": filterReg } ] }
		else
			query = {}

		return Meteor.users.find(query, { limit: instance.limit?.get(), sort: { username: 1, name: 1 } }).fetch()

Template.adminUsers.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminUsers.events
	'keydown #users-filter': (e) ->
		if e.which is 13
			e.stopPropagation()
			e.preventDefault()

	'keyup #users-filter': (e, t) ->
		e.stopPropagation()
		e.preventDefault()
		t.filter.set e.currentTarget.value

	'click .flex-tab .more': ->
		if RocketChat.TabBar.isFlexOpen()
			RocketChat.TabBar.closeFlex()
		else
			RocketChat.TabBar.openFlex()

	'click .user-info': (e) ->
		e.preventDefault()
		Session.set 'adminSelectedUser', $(e.currentTarget).data('id')
		Session.set 'showUserInfo', Meteor.users.findOne($(e.currentTarget).data('id'))?.username or true
		RocketChat.TabBar.setTemplate 'adminUserInfo'
		RocketChat.TabBar.openFlex()

	'click .info-tabs a': (e) ->
		e.preventDefault()
		$('.info-tabs a').removeClass 'active'
		$(e.currentTarget).addClass 'active'

		$('.user-info-content').hide()
		$($(e.currentTarget).attr('href')).show()

	'click .load-more': (e, t) ->
		e.preventDefault()
		e.stopPropagation()
		t.limit.set t.limit.get() + 50
