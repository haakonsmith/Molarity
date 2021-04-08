<template>
    <v-app class="vueWrap" dark>
        <TitleBar/>
        <!-- Navigation menu/header -->
        <Navigation/>
        <!-- Periodic Table -->
        <div class="tableWrap">
            <PeriodicTable/>
        </div>
        <!-- Footer -->
        <div style="clear:both;"></div>
        <div class="footerWrap">
            <Footer/>
        </div>
    </v-app>
</template>

<script>
import PeriodicTable from "./home/PeriodicTable";
import Footer from "./Footer";
import Navigation from "./home/Navigation";
import TitleBar from "./TitleBar";

export default {
    name: "Home",
    components: {
        Navigation,
        PeriodicTable,
        Footer,
        TitleBar
    }
};
</script>

<style lang="scss">
body {
    margin: 0;
}
.application.theme--dark {
    background: rgb(26, 31, 44) !important;
}
.application .theme--dark.v-navigation-drawer .v-divider,
.application
    .theme--dark.v-navigation-drawer:not(.v-navigation-drawer--floating)
    .v-navigation-drawer__border,
.theme--dark .v-navigation-drawer .v-divider,
.theme--dark
    .v-navigation-drawer:not(.v-navigation-drawer--floating)
    .v-navigation-drawer__border {
    background: none;
}
.tableWrap {
    width: 88.1%;
    margin-left: auto;
    margin-right: auto;
    clear: both;
    padding-bottom: 4vw;
}
.footerWrap {
    width: 100%;
}
@media only screen and (max-width: 600px) {
    .tableWrap {
        width: 100%;
        overflow: scroll;
        clear: both;
        padding-bottom: 4vw;
    }
}
</style>