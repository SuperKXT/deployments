/** @satisfies {import('./pm2.types').PM2AppOptions} */
const common = {
	script: './src/app.js',
	instances: 3,
	exec_mode: 'cluster',
	env: {
		NODE_ENV: 'production',
		PORT: 4005,
		IP: '0.0.0.0',
	},
};

/** @type {import('./pm2.types').Pm2Config} */
const config = {
	apps: [
		{
			name: 'backend-production',
			...common,
			env: {
				...common.env,
				NODE_ENV: 'production',
			},
		},
		{
			name: 'backend-dev',
			...common,
			env: {
				...common.env,
				NODE_ENV: 'development',
				PORT: 4006,
			},
		},
		{
			name: 'backend-qa',
			...common,
			env: {
				...common.env,
				NODE_ENV: 'qa',
				PORT: 4007,
			},
		},
	],
};

module.exports = config;
