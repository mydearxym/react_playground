Package.describe({
	name: 'rocketchat:markdown',
	version: '0.0.1',
	summary: 'Message pre-processor that will process selected markdown notations',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'rocketchat:lib@0.0.1'
	]);

	api.addFiles('markdown.coffee', ['server','client']);
});

Package.onTest(function(api) {

});
