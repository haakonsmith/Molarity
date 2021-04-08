module.exports = {
  transpileDependencies: [
    'vuetify'
  ],
  configureWebpack: {
    devtool: 'source-map'
  },
  pluginOptions: {
    electronBuilder: {
        nodeIntegration: true,
        nodeIntegrationInWorker: true
    }
}
}
