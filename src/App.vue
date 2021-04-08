<template>
    <div id="app">
        <router-view></router-view>
    </div>
</template>

<script>
export default {
    name: "App"
};
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,800|Raleway");

html,
body {
    background: rgb(26, 31, 44);
}
html::-webkit-scrollbar {
    display: none;
}
#app {
    font-family: "Open Sans", sans-serif !important;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    height: 100%;
    position: relative;
}
text {
    font-family: "Open Sans", sans-serif !important;
    opacity: 0.9 !important;
}
//Symbol offsets
@media only screen and (min-width: 1600px) {
    text {
        font-family: "Open Sans", sans-serif !important;
        opacity: 0.9 !important;
        transform: translate(0, 0.1em) !important;
    }
}
@media only screen and (max-width: 1300px) {
    text {
        font-family: "Open Sans", sans-serif !important;
        opacity: 0.9 !important;
        transform: translate(0, -0.03em) !important;
    }
}
@media only screen and (max-width: 1050px) {
    text {
        font-family: "Open Sans", sans-serif !important;
        opacity: 0.9 !important;
        transform: translate(0, -0.2em) !important;
    }
}
@media only screen and (max-width: 750px) {
    text {
        font-family: "Open Sans", sans-serif !important;
        opacity: 0.9 !important;
        transform: translate(0, -0.35em) !important;
    }
}
@media only screen and (max-width: 450px) {
    text {
        font-family: "Open Sans", sans-serif !important;
        opacity: 0.9 !important;
        transform: translate(0, -0.3em) !important;
    }
}
</style>
