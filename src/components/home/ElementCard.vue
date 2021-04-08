<template>
    <!-- Class based styling for each element -->
    <div class="element" v-show="mode === 'table' || mode === 'addition'">
        <div class="atomicnumber">
            {{element.atomicNumber}}
            <span>{{element.atomicMass}}</span>
        </div>
        <div class="symbol">{{element.symbol}}</div>
        <div class="name">{{element.name}}</div>
    </div>
</template>

<script>
import { TweenMax } from "gsap";

export default {
    name: "ElementCard",
    props: ["element", "mode"],
    data() {
        return {
            loaded: false
        };
    },
    mounted: function() {
        if (this.loaded === false) {
            TweenMax.to(".element", 0.7, { opacity: 1 });
        }
        this.loaded = true;
    },
    methods: {
        //convert dataset atomic mass to standard atomic mass
        convertMass(element) {
            var n = element.atomicNumber;
            var m = element.atomicMass;
            var exceptions = [
                57,
                58,
                59,
                60,
                62,
                63,
                64,
                65,
                66,
                67,
                68,
                69,
                70,
                71,
                90,
                91,
                92
            ];
            if (
                (n <= 83 && n !== 61 && n !== 43) ||
                exceptions.indexOf(n) > -1
            ) {
                m = m.slice(0, -3);
                return parseFloat(parseFloat(m).toFixed(3));
            } else {
                return m.toString();
            }
        }
    }
};
</script>

<style lang="scss" scoped>
.element {
    color: rgba(255, 255, 255, 0.55);
    width: 100%;
    height: 100%;
    // max-width: 4.86vw;
    opacity: 0;
    // max-height: 4.86vw;
    overflow: hidden;
    text-align: center;
    padding: 0.2vw;
    transition: opacity 0.4s;
    .atomicnumber {
        text-align: left;
        color: rgba(255, 255, 255, 0.55);
        font-size: 0.65vw;
        font-weight: 200;
        span {
            float: right;
            color: rgba(255, 255, 255, 0);
            font-weight: 200;
        }
    }
    .name {
        font-size: 0.67vw;
        margin-top: -0.24vw;
        opacity: 0.9;
        font-weight: 200;
    }
    .symbol {
        font-weight: 600;
        font-size: 1.8vw;
        line-height: 2.5vw;
    }
    &:hover {
        color: rgba(255, 255, 255, 0.9);
    }
}
//element fade delays
.l1 {
    transition-delay: 0ms;
}
.l2 {
    transition-delay: 80ms;
}
.l3 {
    transition-delay: 160ms;
}
.l4 {
    transition-delay: 230ms;
}
.l5 {
    transition-delay: 300ms;
}
.l6 {
    transition-delay: 360ms;
}
.l7 {
    transition-delay: 420ms;
}
.l8 {
    transition-delay: 470ms;
}
.l9 {
    transition-delay: 510ms;
}
.l10 {
    transition-delay: 550ms;
}
.l11 {
    transition-delay: 580ms;
}
.l12 {
    transition-delay: 610ms;
}
.l13 {
    transition-delay: 620ms;
}
//group colors
.alkali {
    background-color: rgba(114, 47, 61, 0.8);
    &:hover {
        background-color: rgba(100, 50, 60, 0.5);
    }
}
.alkaliEarth {
    background-color: rgba(95, 70, 55, 0.8);
    &:hover {
        background-color: rgba(93, 73, 61, 0.5);
    }
}
.transitionMetal {
    background-color: rgba(58, 70, 90, 0.8);
    &:hover {
        background-color: rgba(59, 73, 98, 0.5);
    }
}
.noble {
    background-color: rgba(87, 49, 126, 0.8);
    &:hover {
        background-color: rgba(96, 60, 130, 0.5);
    }
}
.halogen {
    background-color: rgba(77, 74, 150, 0.8);
    &:hover {
        background-color: rgba(102, 100, 161, 0.5);
    }
}
.nonMetal {
    background-color: rgba(53, 54, 119, 0.8);
    &:hover {
        background-color: rgba(46, 48, 108, 0.5);
    }
}
.metalloid {
    background-color: rgba(21, 84, 100, 0.8);
    &:hover {
        background-color: rgba(34, 74, 106, 0.5);
    }
}
.postTransition {
    background-color: rgba(28, 100, 73, 0.8);
    &:hover {
        background-color: rgba(34, 94, 79, 0.5);
    }
}
.lanthanoid {
    background-color: rgba(74, 57, 110, 0.8);
    &:hover {
        background-color: rgba(80, 67, 111, 0.5);
    }
}
.actinoid {
    background-color: rgba(64, 37, 80, 0.8);
    &:hover {
        background-color: rgba(62, 41, 73, 0.5);
    }
}
@media only screen and (max-width: 600px) {
    .element {
        width: 100%;
        height: 100%;
        box-sizing: border-box;
        text-align: center;
        padding: 0.4vw;
        transition: 0.2s;
        transition-timing-function: ease;
        .atomicnumber {
            text-align: left;
            font-size: 1.2vw;
            span {
                float: right;
            }
        }
        .name {
            font-size: 1.3vw;
            margin-top: 0;
            opacity: 0.9;
        }
        .symbol {
            font-weight: 600;
            font-size: 4vw;
            line-height: 4.5vw;
        }
    }
}
</style>
