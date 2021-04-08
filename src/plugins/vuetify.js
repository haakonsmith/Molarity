import Vue from 'vue';
import Vuetify from 'vuetify/lib/framework';

Vue.use(Vuetify);

export default new Vuetify({
    theme: {
        themes: {
            dark: {
                // primary: '#232937',
                // secondary: '#282e3c',
                // accent: '#303747',
                // info: '#323642',
                // error: '#ff643d',
            }
        },
        dark: true
    }
});
