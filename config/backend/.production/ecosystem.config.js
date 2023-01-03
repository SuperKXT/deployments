const common = {
  script: "./src/app.js",
  instances: 3,
  Exec_mode: "cluster",
  env: {
    IP: '0.0.0.0',
  },
};

module.exports = {
  apps: [
    {
      name: 'backend-production',
      ...common,
      env: {
        ...common.env,
        NODE_ENV: 'production',
        PORT: 4005,
      },
    },
    {
      name: 'backend-qa',
      ...common,
      env: {
        ...common.env,
        NODE_ENV: 'qa',
        PORT: 4006,
      },
    },
    {
      name: 'backend-dev',
      ...common,
      env: {
        ...common.env,
        NODE_ENV: 'development',
        PORT: 4007,
      },
    },
  ]
};
