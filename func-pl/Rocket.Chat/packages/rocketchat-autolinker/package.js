Package.describe({
	name: 'rocketchat:autolinker',
	version: '0.0.1',
	summary: 'Message pre-processor that will translate links on messages',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'konecty:autolinker',
		'rocketchat:lib@0.0.1'
	]);

	api.addFiles('autolinker.coffee', ['server','client']);
});

Package.onTest(function(api) {

});
