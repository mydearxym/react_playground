RocketChat.TabBar = new class
	$tabBar = {}
	$tabButtons = {}

	buttons = new ReactiveVar {}

	animating = false
	open = new ReactiveVar false
	template = new ReactiveVar ''
	data = new ReactiveVar {}

	setTemplate = (t, callback) ->
		return if animating is true
		template.set t
		openFlex(callback)

	getTemplate = ->
		return template.get()

	setData = (d) ->
		data.set d

	getData = ->
		return data.get()

	openFlex = (callback) ->
		return if animating is true
		toggleFlex 1, callback

	closeFlex = (callback) ->
		return if animating is true
		toggleFlex -1, callback

	toggleFlex = (status, callback) ->
		return if animating is true
		animating = true

		if status is -1 or (status isnt 1 and open.get())
			open.set false
		else
			# added a delay to make sure the template is already rendered before animating it
			setTimeout ->
				open.set true
			, 50
		setTimeout ->
			animating = false
			callback?()
		, 500

	show = ->
		$('.flex-tab-bar').show()
	
	hide = ->
		closeFlex()
		$('.flex-tab-bar').hide()

	isFlexOpen = ->
		return open.get()

	addButton = (config) ->
		unless config?.id
			throw new Meteor.Error "tabBar-addButton-error", "Button id was not informed."
		
		Tracker.nonreactive ->
			btns = buttons.get()
			btns[config.id] = config
			buttons.set btns

	removeButton = (id) ->
		Tracker.nonreactive ->
			btns = buttons.get()
			delete btns[id]
			buttons.set btns

	updateButton = (id, config) ->
		Tracker.nonreactive ->
			btns = buttons.get()
			if btns[id]
				btns[id] = _.extend btns[id], config 
				buttons.set btns

	getButtons = ->
		return _.sortBy (_.toArray buttons.get()), 'order'

	reset = ->
		animating = false
		resetButtons()
		closeFlex()
		template.set ''
		data.set {}

	resetButtons = ->
		buttons.set {}

	setTemplate: setTemplate
	setData: setData
	getTemplate: getTemplate
	getData: getData
	openFlex: openFlex
	closeFlex: closeFlex
	isFlexOpen: isFlexOpen
	show: show
	hide: hide
	addButton: addButton
	updateButton: updateButton
	removeButton: removeButton
	getButtons: getButtons
	reset: reset
	resetButtons: resetButtons
