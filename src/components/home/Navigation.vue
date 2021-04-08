<template>
    <div class="nav">
        <!--Toggle for hamburger menu-->
        <!-- <span class="menuWrap" :style="menuPreload">
            <Menu/>
        </span> -->
        <!-- Dynamic page header -->
        <h1 class="mainTitle">
            Molarity
            <br>
            <p>
                <span
                    class="modeSelect"
                    v-ripple
                    :class="isActive('table')"
                    id="m1"
                    @click="changeMode('table')"
                >Table</span>
                <span
                    class="modeSelect"
                    v-ripple
                    :class="isActive('trends')"
                    id="m2"
                    @click="changeMode('trends')"
                >Trends</span>
            </p>
        </h1>
    </div>
</template>

<!-- eslint-disable vue/no-unused-components -->
<script>
import { TweenMax } from 'gsap';
import Menu from "./Menu";


export default {
    name: "Navigation",
    components: {
        Menu
    },
    data() {
        return {
            activeMode: "table"
        };
    },
    mounted: function() {
        TweenMax.to(".mainTitle", 0.5, { opacity: 1, delay: 0.5 });
        this.$root.$on("pushChange", text => {
            this.activeMode = text;
        });
    },
    methods: {
        //handle mode change
        changeMode(mode) {
            if (mode === "trends") {
                document.getElementById("m1").classList.remove("active");
                document.getElementById("m2").classList.add("active");
            } else {
                document.getElementById("m2").classList.remove("active");
                document.getElementById("m1").classList.add("active");
                this.$root.$emit("defaultCurrent", `Add default current`);
            }
            this.$root.$emit(`${mode}`, `Changed mode to ${mode}`);
        },
        isActive(mode) {
            if (this.activeMode === mode) {
                return "active";
            } else return "";
        }
    }
};
</script>

<style lang="scss" scoped>
.nav {
    width: 100%;
    padding: 3.7vw 0 2vw 0;
    display: flex;
    justify-content: center;
    .menuWrap {
        float: left;
        transition: 0.5s;
    }
    h1.mainTitle {
        width: 50%;
        text-align: center;
        color: rgba(255, 255, 255, 0.9);
        font-weight: 300;
        font-size: 2.6vw;
        opacity: 0;
        transition: 0.5s;
        p {
            text-align: center;
            font-size: 0;
            position: relative;
            z-index: 900000009;
        }
        .modeSelect {
            display: inline;
            opacity: 0.3;
            transition: 0.5s ease;
            font-weight: 300;
            padding: 0.15vw 0.5vw;
            font-size: 1.3vw;
            border-radius: 0.2vw;

            background: rgba(255, 255, 255, 0.1);
            &:hover {
                cursor: pointer;
                opacity: 0.6;
            }
        }
        #m1 {
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
        }
        #m2 {
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
        }
        .active {
            opacity: 1;
            &:hover {
                cursor: auto;
                opacity: 1;
            }
        }
    }
}
@media only screen and (max-width: 600px) {
    .nav {
        width: 100%;
        padding: 6vw;
        .menuWrap {
            float: left;
        }
        h1 {
            width: 37%;
            text-align: center;
            color: rgba(255, 255, 255, 0.9);
            font-weight: 300;
            font-size: 5.3vw;
            .modeSelect {
                opacity: 0.3;
                transition: 0.5s ease;
                position: absolute;
                margin-top: 5.6vw;
                margin-left: 1vw;
                font-weight: 300;
                z-index: 3;
                font-size: 4vw;
                &:hover {
                    cursor: pointer;
                    opacity: 0.6;
                }
            }
            .active {
                opacity: 1;
                font-size: 5.3vw;
                margin-top: 0;
                &:hover {
                    cursor: auto;
                    opacity: 1;
                }
            }
        }
    }
}
</style>
