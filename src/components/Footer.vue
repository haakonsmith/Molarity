<template>
    <v-footer height="auto" :style="'width: '+ width">
            <div class="about">
                Periodicity is the tendency for periodic elements to form patterns, this MIT licensed tool aims to help in day to day use of a periodic table.
            </div>
            <div class="copy">
                &copy;{{new Date().getFullYear()}} -
                <span>Haakon Smith</span>
            </div>
            <!-- <v-flex primary py-2 text-xs-center xs12 class="copy">
                
            </v-flex> -->
    </v-footer>
</template>

<script>
export default {
    name: "Footer",
    props: ["width"],
    data: () => ({
        links: ["Help", "", "Team", "", "Github"]
    })
};
</script>

<style lang="scss" scoped>
* {
    opacity: 0.85;
    font-weight: 200;
}
footer {
    color: rgba(255, 255, 255, 0.7);
    font-size: 16px;
    padding-bottom: 10px;
    margin: 1vw auto auto auto;
}
.about {
    width: 100%;
    padding: 10px;
    margin-bottom: 10px;
}
.copy {
    padding: 10px;
    background-color: rgb(24, 8, 34);
    width: 100%;
}
.v-footer {
    background: rgb(26, 31, 44) !important;
    color: rgba(255, 255, 255, 0.8) !important;
    width: 88%;
    padding: 0;
}
// .about {
//     margin: -16px;
//     padding-top: 20px !important;
//     // border-bottom: 0.5px solid rgba(240, 240, 240, 0.5);
//     // padding-bottom: 20px;
//     font-size: 15px;
//     a {
//         text-decoration: none;
//         color: rgba(255, 255, 255, 0.6);
//     }
// }
// span {
//     font-weight: 400;
// }
@media only screen and (max-width: 600px) {
    footer {
        color: rgba(255, 255, 255, 0.7);
        margin: 4vw auto auto auto;
        font-size: 12px;
    }
    .v-footer {
        background: rgba(30, 36, 50, 1);
        color: rgba(255, 255, 255, 0.8);
        width: 90%;
        .copy {
            background: none !important;
            border: none !important;
        }
    }
    .about {
        font-size: 10px;
    }
}
</style>
