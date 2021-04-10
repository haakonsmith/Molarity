/* eslint-disable vue/no-use-v-if-with-v-for */
/* eslint-disable no-unused-vars */
<template>
  <div width="100%" id="table">
    <!-- Spacers to create shape of periodic table -->
    <div class="spacer1"></div>
    <div class="spacer2"></div>
    <div class="infoWrapper">
      <!-- Introduction -->
      <div v-if="!current & (mode === 'table')" class="introduction">
        <div class="features">
          <div class="tips">
            <!-- <div
                            v-for="point in points"
                            :key="point.description"
                            :class="point.class+' point'"
                        >
                            <v-icon :style="{color: point.color}">{{point.icon}}</v-icon>
                            <p>{{point.description}}</p>
                        </div>-->
            <div class="point p3">
              <v-icon style="color: slategrey">library_add</v-icon>
              <div style="clear: both"></div>
              <span>Right Click</span>

              <p><br />to mass <br />compounds</p>
            </div>
            <div class="point p2">
              <v-icon style="color: lightsteelblue">poll</v-icon>
              <div style="clear: both"></div>

              <span>Switch Modes</span>

              <p><br />to navigate to <br />periodic trends</p>
            </div>
            <div class="point p1">
              <v-icon style="color: lightblue">assignment</v-icon>
              <div style="clear: both"></div>

              <span>Click Element</span>

              <p><br />to navigate to <br />a detailed page</p>
            </div>
          </div>
          <div>
            <chemical-element-visualisation
              symbol="pt"
              class="atom-model"
            ></chemical-element-visualisation>
          </div>
        </div>
      </div>
      <!-- Element-hover triggered details -->
      <InfoBox
        v-else-if="current && mode === 'table'"
        :element="current"
        :animations="animations"
      />
      <!-- Element-right-click triggered atomic mass calculator -->
      <AddBox
        v-else-if="mode === 'addition'"
        :elements="toBeSummed"
        :symbols="toBeSummedElements"
      />
      <!-- Periodic Trends graphing controller -->
      <TrendBox v-else :current="currentForTrend" />
    </div>
    <div class="spacer3"></div>
    <!-- Loop over main-block elements in dataset, create element card -->
    <!-- eslint-disable-next-line vue/no-use-v-if-with-v-for -->
    <div v-if="isMain(element)"
      v-for="element in elements"
      :key="element.atomicNumber"
      class="elementWrapper"
      @mouseenter="currentElement(element)"
      @mouseleave="clearCurrentForTrend()"
      @click.right="beginSumming(element)"
      oncontextmenu="return false;"
      style="z-index: 2"
    >
      <router-link
        :to="{ path: '/element/' + element.atomicNumber }"
        class="routerWrap"
      >
        <ElementCard
          :mode.sync="mode"
          :element="element"
          :key="'ecard' + element.atomicNumber"
          :class="createElementClass(element)"
        />
        <!-- Alternate card used when Periodic Trends mode is activated  -->
        <TrendCard
          :trendToDisplay="trend"
          :mode.sync="mode"
          :element="element"
          :key="'tcard' + element.atomicNumber"
          :class="createElementClass(element)"
        />
      </router-link>
    </div>
    <div v-for="group in 18" :key="'group-' + group" class="group-label">
      {{ romanize(group) }}
    </div>
    <div class="spacer5"></div>
    <div class="spacer6"></div>
    <div class="spacer7"></div>
    <!-- For Lanthanides/Actinides, seperate from main elements -->
    <!-- eslint-disable-next-line vue/no-use-v-if-with-v-for -->
    <div v-if="isBlockF(element)"
      v-for="element in elements"
      :key="'f' + element.atomicNumber"
      class="elementWrapper"
      @mouseenter="currentElement(element)"
      @mouseleave="clearCurrentForTrend()"
      @click.right="beginSumming(element)"
      oncontextmenu="return false;"
      style="z-index: 2"
    >
      <router-link
        :to="{ path: '/element/' + element.atomicNumber }"
        class="routerWrap"
      >
        <ElementCard
          :mode.sync="mode"
          :element="element"
          :key="'ecard' + element.atomicNumber"
          :class="createElementClass(element)"
        />
        <TrendCard
          :trendToDisplay="trend"
          :mode.sync="mode"
          :element="element"
          :key="'tcard' + element.atomicNumber"
          :class="createElementClass(element)"
        />
      </router-link>
    </div>
    <!-- Premature hover handler -->
    <div class="hoverBlock"></div>
  </div>
</template>

<script>
import ElementCard from "./ElementCard";
import TrendCard from "./TrendCard";
import TrendBox from "./TrendBox";
import InfoBox from "./InfoBox";
import AddBox from "./AddBox";
import Elements from "@/elements";
import { TimelineMax } from "gsap";

export default {
  name: "PeriodicTable",
  data() {
    return {
      elements: Elements,
      mode: "table",
      atomGraph: null,
      introBohr: "",
      animations: true,
      toBeSummed: [],
      toBeSummedElements: [],
      current: null,
      currentForTrend: null,
      trend: "Ionization Energy",
      //animation load orders by atomic number
      nonMetal: [1, 6, 7, 8, 15, 16, 34],
      alkali: [3, 11, 19, 37, 55, 87],
      akaliEarth: [4, 12, 20, 38, 56, 88],
      // prettier-ignore
      transitionMetal: [21, 22,23, 24, 25, 26, 27, 28, 29, 30, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 72, 73, 74, 75, 76, 77, 78, 79, 80, 104, 105, 106, 107, 108, 109, 110, 111, 112],
      postTransition: [13, 31, 49, 50, 81, 82, 83, 113, 114, 115, 116],
      metalloid: [5, 14, 32, 33, 51, 52, 84],
      halogen: [9, 17, 35, 53, 85, 117],
      noble: [2, 10, 18, 36, 54, 86, 118],
      lanthanoid: [57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71],
      actinoid: [
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        98,
        99,
        100,
        101,
        102,
        103,
      ],
      //creates staggered page load effect
      loadOrder: {
        1: [1, 103],
        2: [3, 102, 71, 118],
        3: [11, 4, 101, 70, 117, 86],
        4: [19, 12, 100, 69, 116, 85, 54],
        5: [37, 20, 99, 68, 115, 84, 53, 36],
        6: [55, 38, 21, 98, 67, 114, 83, 52, 35, 18],
        7: [87, 56, 39, 22, 97, 66, 113, 82, 51, 34, 17, 10],
        8: [88, 40, 23, 96, 65, 112, 81, 50, 33, 16, 9, 2],
        9: [72, 41, 24, 95, 64, 111, 80, 49, 32, 15, 8],
        10: [57, 104, 73, 42, 25, 94, 63, 110, 79, 48, 31, 14, 7],
        11: [89, 58, 105, 74, 43, 26, 93, 62, 109, 78, 47, 30, 13, 6],
        12: [90, 59, 106, 75, 44, 27, 92, 61, 108, 77, 46, 29, 5],
        13: [91, 60, 107, 76, 45, 28],
      },
    };
  },
  components: {
    ElementCard,
    InfoBox,
    TrendCard,
    TrendBox,
    AddBox,
  },
  mounted: function () {
    this.block = "display: block";
    var t1 = new TimelineMax();
    t1.to(".hoverBlock", 0, { display: "block" })
      .from(".p1", 1, { opacity: 0, y: 10 }, "1")
      .from(".p2", 1, { opacity: 0, y: 10 }, "-=0.6")
      .from(".p3", 1, { opacity: 0, y: 10 }, "-=0.6")
      .from(".p4", 1, { opacity: 0, y: 10 }, "-=0.6")
      .to(".hoverBlock", 0, { display: "none" }, "-=0.6");
    setTimeout(() => {
      this.block = "display: none";
    }, 3000);

    //global recievers
    this.$root.$on("trends", () => {
      this.mode = "trends";
    });
    this.$root.$on("table", () => {
      this.mode = "table";
    });
    this.$root.$on("defaultCurrent", () => {
      this.current = this.elements[0];
    });
    this.$root.$on("toggleAnimations", () => {
      this.animations = !this.animations;
    });
    this.$root.$on("displayTrend", (text) => {
      this.trend = text;
    });
    this.$root.$on("exitAddition", () => {
      this.mode = "table";
      this.toBeSummed = [];
      this.toBeSummedElements = [];
    });
  },
  watch: {
    //toggle mode
    mode: function () {
      this.trend = "Ionization Energy";
      if (this.mode === "trends") {
        this.block = "display: block";
        setTimeout(() => {
          this.block = "display: none";
        }, 600);
      }
    },
    //animation hover buffer
    trend: function () {
      this.block = "display: block";
      setTimeout(() => {
        this.block = "display: none";
      }, 600);
    },
    //remove introduction model on element hover
    current: function () {
      this.introBohr = "display: none";
    },
  },
  methods: {
    romanize(num) {
      if (isNaN(num)) return NaN;
      var digits = String(+num).split(""),
        key = [
          "",
          "C",
          "CC",
          "CCC",
          "CD",
          "D",
          "DC",
          "DCC",
          "DCCC",
          "CM",
          "",
          "X",
          "XX",
          "XXX",
          "XL",
          "L",
          "LX",
          "LXX",
          "LXXX",
          "XC",
          "",
          "I",
          "II",
          "III",
          "IV",
          "V",
          "VI",
          "VII",
          "VIII",
          "IX",
        ],
        roman = "",
        i = 3;
      while (i--) roman = (key[+digits.pop() + i * 10] || "") + roman;
      return Array(+digits.join("") + 1).join("M") + roman;
    },
    //atomic mass calculator addition
    beginSumming(element) {
      this.mode = "addition";
      this.toBeSummed.push(element.atomicMass);
      this.toBeSummedElements.push(element.symbol);
    },
    //determine whether element is main or lanth/act
    isMain(element) {
      var n = element.atomicNumber;
      return n < 57 || n >= 104 || (n >= 72 && n < 89);
    },
    isBlockF(element) {
      var n = element.atomicNumber;
      return !(n < 57 || n >= 104 || (n >= 72 && n < 89));
    },
    //create class for each element, used for styling in individual cards
    createElementClass(element) {
      var n = element.atomicNumber;
      var loadIndex = "";
      Object.entries(this.loadOrder).forEach(([key, value]) => {
        if (value.includes(n)) {
          loadIndex += key.toString();
        }
      });
      if (this.nonMetal.includes(n)) {
        return "nonMetal l" + loadIndex;
      } else if (this.alkali.includes(n)) {
        return "alkali l" + loadIndex;
      } else if (this.akaliEarth.includes(n)) {
        return "alkaliEarth l" + loadIndex;
      } else if (this.transitionMetal.includes(n)) {
        return "transitionMetal l" + loadIndex;
      } else if (this.postTransition.includes(n)) {
        return "postTransition l" + loadIndex;
      } else if (this.halogen.includes(n)) {
        return "halogen l" + loadIndex;
      } else if (this.noble.includes(n)) {
        return "noble l" + loadIndex;
      } else if (this.lanthanoid.includes(n)) {
        return "lanthanoid l" + loadIndex;
      } else if (this.actinoid.includes(n)) {
        return "actinoid l" + loadIndex;
      } else if (this.metalloid.includes(n)) {
        return "metalloid l" + loadIndex;
      }
    },
    //handles element hover
    currentElement(element) {
      this.current = element;
      this.currentForTrend = element;
    },
    clearCurrentForTrend() {
      this.currentForTrend = null;
    },
  },
};
</script>

<style lang="scss">
.atom-model {
  z-index: 0;
  position: absolute;
  margin-top: -5vw;
  margin-left: 30.55vw;
  width: 15vw;
  // height: 21vw;
  float: right;
  --alkali-metal-primary-color: rgba(192, 63, 95, 0.8);
  --alkaline-earth-metal-primary-color: rgba(151, 103, 73, 0.8);
  --transition-metal-primary-color: rgba(91, 113, 150, 0.8);
  --post-transition-metal-primary-color: rgba(70, 153, 132, 0.8);
  --metalloid-primary-color: rgba(70, 134, 160, 0.8);
  --other-nonmetal-primary-color: rgba(87, 91, 192, 0.8);
  --halogen-primary-color: rgba(122, 120, 202, 0.8);
  --noble-gas-primary-color: rgba(136, 92, 177, 0.8);
  --lanthanide-primary-color: rgba(136, 109, 199, 0.8);
  --actinide-primary-color: rgba(138, 81, 168, 0.8);
  --chemical-element-visualisation-background-color: transparent;
}
.spacer1 {
  grid-area: wz;
}
.spacer2 {
  grid-area: wa;
}
sup {
  font-size: 1.5vw;
}
.group-label {
  height: 2vw;
  font-size: 0.8em;
  text-align: center;
}
.infoWrapper {
  grid-area: wb;
  .introduction {
    width: 100%;
    height: 100%;
    padding: 1vw 1.5vw 0 1.5vw;
    line-height: 1.3vw;
    transition: 1s;
    margin-top: 0.5vw;
    .features {
      text-align: center;
      color: rgba(255, 255, 255, 0.8);
      width: 100%;
      height: 100%;
      margin-top: -0.1vw;
      .tips {
        width: 68%;
        margin-top: 2.5vw;
        .point {
          width: 32.5%;
          float: right;
          text-align: center;
          height: 3.1vw;
          padding: 0.45vw;
          margin-top: -2.4vw;
          font-weight: 300;
          font-size: 1.05vw;
          span {
            font-size: 1.2vw;
            font-weight: 400;
            float: none;
            text-align: center;
            letter-spacing: 0.03vw;
          }
          p {
            margin-top: -1vw !important;
            margin: auto;
            color: rgba(255, 255, 255, 0.6);
            line-height: 1.2vw;
            letter-spacing: 0.035vw;
          }
          i {
            text-align: center;
            font-size: 4.1vw;
            opacity: 0.7;
            margin-top: 1vw;
            margin-bottom: 0.35vw;
          }
        }
      }
      #bohr-intro-container {
        z-index: 0;
        position: absolute;
        margin-top: -7.3vw;
        margin-left: 28vw;
        width: 21vw;
        height: 21vw;
        float: right;
      }
    }
  }
}
.spacer3 {
  grid-area: wc;
}
.spacer4 {
  grid-area: wd;
  height: 2vw;
}
.spacer5 {
  grid-area: we;
}
.spacer6 {
  grid-area: wf;
}
.spacer7 {
  grid-area: wg;
}
#table {
  margin-top: 1vw;
  float: right;
  gap: 1px;
  display: inline-grid;
  grid-template-columns: repeat(18, 1fr);
  grid-template-areas:
    ".  wa wb wb wb wb wb wb wb wb wb wb wz wz wz wz wz ."
    ".  .  wb wb wb wb wb wb wb wb wb wb .  .  .  .  .  ."
    ".  .  wb wb wb wb wb wb wb wb wb wb .  .  .  .  .  ."
    ".  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
    ".  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
    ".  .  wc .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
    ".  .  wc .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
    ".  .  . .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
    "we we .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  wg "
    "wf wf .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . ";
  .elementWrapper {
    display: flex;
    justify-content: center;
    width: 4.86vw;
    height: 4.86vw;
    .routerWrap {
      object-fit: cover;
      width: 100%;
      height: 100%;
      text-decoration: none;
    }
  }
  .hoverBlock {
    display: none;
    position: absolute;
    width: 100%;
    height: 100%;
    z-index: 1000;
  }
}
@media only screen and (max-width: 600px) {
  .spacer1 {
    grid-area: wz;
  }
  .spacer2 {
    grid-area: wa;
  }
  sup {
    font-size: 1.5vw;
  }
  .infoWrapper {
    grid-area: wb;
    .introduction {
      display: none;
    }
  }
  .spacer3 {
    grid-area: wc;
  }
  .spacer4 {
    grid-area: wd;
    height: 2vw;
  }
  .spacer5 {
    grid-area: we;
  }
  .spacer6 {
    grid-area: wf;
  }
  .spacer7 {
    grid-area: wg;
  }
  #table {
    margin-top: 1vw;
    float: right;
    border-right: 5vw;
    display: inline-grid;
    width: 100vw;
    grid-template-columns: repeat(18, 1fr);
    grid-template-areas:
      ".  wa wb wb wb wb wb wb wb wb wb wb wz wz wz wz wz ."
      ".  .  wb wb wb wb wb wb wb wb wb wb .  .  .  .  .  ."
      ".  .  wb wb wb wb wb wb wb wb wb wb .  .  .  .  .  ."
      ".  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
      ".  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
      ".  .  wc .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
      ".  .  wc .  .  .  .  .  .  .  .  .  .  .  .  .  .  ."
      "wd wd wd wd wd wd wd wd wd wd wd wd wd wd wd wd wd wd"
      "we we .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  wg "
      "wf wf .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . ";
    .elementWrapper {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 10vw;
      height: 10vw;
      .routerWrap {
        width: 100%;
        height: 100%;
        text-decoration: none;
      }
    }
    .hoverBlock {
      position: absolute;
      width: 100%;
      height: 100%;
      z-index: 1000;
    }
  }
}
</style>
