Package.describe({
	name: 'rocketchat:livechat',
	version: '0.0.1',
	summary: 'Livechat plugin for Rocket.Chat'
});

Package.registerBuildPlugin({
	name: "builLivechat",
	use: [],
	sources: [
		'plugin/build-livechat.js'
	],
	npmDependencies: {
		"shelljs": "0.5.1"
	}
});

// Loads all i18n.json files into tapi18nFiles
var _ = Npm.require('underscore');
var fs = Npm.require('fs');
tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/rocketchat-livechat/i18n'), function(filename) {
	if (fs.statSync('packages/rocketchat-livechat/i18n/' + filename).size > 16) {
		return 'i18n/' + filename;
	}
}));

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use(['coffeescript', 'webapp', 'autoupdate'], 'server');
	api.use('templating', 'client');
	api.use(["tap:i18n@1.5.1"], ["client", "server"]);
	api.imply('tap:i18n');
	api.addFiles("package-tap.i18n", ["client", "server"]);

	api.addFiles('livechat.coffee', 'server');
	api.addFiles('methods.coffee', 'server');
	api.addFiles('publications.coffee', 'server');

	api.addFiles('config.js', 'server');

	api.addFiles('rocket-livechat.js', 'client', {isAsset: true});
	api.addFiles('public/livechat.css', 'client', {isAsset: true});
	api.addFiles('public/livechat.js', 'client', {isAsset: true});
	api.addFiles('public/head.html', 'server', {isAsset: true});

	api.addFiles(tapi18nFiles, ["client", "server"]);
});
