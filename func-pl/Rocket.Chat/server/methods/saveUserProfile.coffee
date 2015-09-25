Meteor.methods
	saveUserProfile: (settings) ->
		if Meteor.userId()
			if settings.language?
				RocketChat.models.Users.setLanguage Meteor.userId(), settings.language

			if settings.password?
				Accounts.setPassword Meteor.userId(), settings.password, { logout: false }

			if settings.username?
				Meteor.call 'setUsername', settings.username

			profile = {}

			RocketChat.models.Users.setProfile Meteor.userId(), profile

			return true
