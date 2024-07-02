{
	api_wrapper => 'WithStatus',
	api_resources => {
		'Test' => '/test',
		'Test::Deep' => {
			path => '/deep',
			formatter => 'YAML',
		},
	},
}

