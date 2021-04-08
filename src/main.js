import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify';
import router from './router'
import VueFractionGrid from "vue-fraction-grid";

Vue.config.productionTip = false

Vue.use(VueFractionGrid);

process.on('unhandledRejection', (error) => {
  console.error(error)
})

new Vue({
  vuetify,
  router,
  render: h => h(App)
}).$mount('#app')
