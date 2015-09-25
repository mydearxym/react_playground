RocketChat.MessageAction = new class
	buttons = new ReactiveVar {}
	
	###
	config expects the following keys (only id is mandatory):
		id (mandatory)
		icon: string
		i18nLabel: string
		action: function(event, instance)
		validation: function(message)
		order: integer
	### 
	addButton = (config) ->
		unless config?.id
			throw new Meteor.Error "MessageAction-addButton-error", "Button id was not informed."

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

	getButtons = (message) ->
		allButtons = _.toArray buttons.get()
		if message
			allowedButtons = _.compact _.map allButtons, (button) -> 
				unless button.validation?
					return true
				if button.validation(message)
					return button
		else
			allowedButtons = allButtons
		
		return _.sortBy allowedButtons, 'order'

	resetButtons = ->
		buttons.set {}

	addButton: addButton
	removeButton: removeButton
	updateButton: updateButton
	getButtons: getButtons
	resetButtons: resetButtons

Meteor.startup ->
	RocketChat.MessageAction.addButton
		id: 'edit-message'
		icon: 'icon-pencil'
		i18nLabel: 'rocketchat-lib:Edit'
		action: (event, instance) ->
			message = $(event.currentTarget).closest('.message')[0]
			instance.chatMessages.edit(message)
			$("\##{message.id} .message-dropdown").hide()
			input = instance.find('.input-message')
			Meteor.setTimeout ->
				input.focus()
			, 200
		validation: (message) ->
			hasPermission = RocketChat.authz.hasAtLeastOnePermission('edit-message', message.rid)
			isEditAllowed = RocketChat.settings.get 'Message_AllowEditing'
			editOwn = message.u?._id is Meteor.userId()

			return unless hasPermission or (isEditAllowed and editOwn)

			blockEditInMinutes = RocketChat.settings.get 'Message_AllowEditing_BlockEditInMinutes'
			if blockEditInMinutes? and blockEditInMinutes isnt 0
				msgTs = moment(message.ts) if message.ts?
				currentTsDiff = moment().diff(msgTs, 'minutes') if msgTs?
				return currentTsDiff < blockEditInMinutes
			else
				return true
		order: 1

	RocketChat.MessageAction.addButton
		id: 'delete-message'
		icon: 'icon-trash-1'
		i18nLabel: 'rocketchat-lib:Delete'
		action: (event, instance) ->
			message = @_arguments[1]
			msg = $(event.currentTarget).closest('.message')[0]
			$("\##{msg.id} .message-dropdown").hide()
			return if msg.classList.contains("system")
			swal {
				title: t('Are_you_sure')
				text: t('You_will_not_be_able_to_recover')
				type: 'warning'
				showCancelButton: true
				confirmButtonColor: '#DD6B55'
				confirmButtonText: t('Yes_delete_it')
				cancelButtonText: t('Cancel')
				closeOnConfirm: false
				html: false
			}, ->
				swal
					title: t('Deleted')
					text: t('Your_entry_has_been_deleted')
					type: 'success'
					timer: 1000
					showConfirmButton: false

				instance.chatMessages.deleteMsg(message)
		validation: (message) ->
			return RocketChat.authz.hasAtLeastOnePermission('delete-message', message.rid ) or RocketChat.settings.get('Message_AllowDeleting') and message.u?._id is Meteor.userId()
		order: 2