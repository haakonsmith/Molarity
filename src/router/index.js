import Vue from 'vue'
import Home from '../components/Home'
import ElementPage from '../components/ElementPage'
import Router from 'vue-router'

Vue.use(Router);

const routes = [{
    path: '/', // Homepage
    component: Home
  },
  {
    path: '/element/:id', // Individualized element pages
    component: ElementPage
  },
  {
    path: '*', // Redirect bad routes to Homepage
    redirect: '/'
  }
]

// eslint-disable-next-line no-unused-vars
const Foo = () => import('@/components/ElementPage.vue')

export default new Router({
  routes,
  mode: 'hash' // Pretty links
})
