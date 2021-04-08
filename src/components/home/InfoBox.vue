/* eslint-disable vue/no-unused-vars */
<template>
  <div class="box">
    <!-- Element header -->
    <div class="header">
      <span class="name" :class="classify(element)[1]">{{
        element.atomicNumber + " - " + element.name
      }}</span>
      <br />
      <span class="classification" :class="classify(element)[1]">{{
        classify(element)[0]
      }}</span>
    </div>
    <!-- Element details -->
    <div class="info">
      <div class="state">
        <p>Phase</p>
        <img v-bind:src="getImg(element.standardState)" />
      </div>
      <div class="display">
        <p class="label">Atomic Mass</p>
        <p class="value">{{ element.atomicMass }}</p>
      </div>
      <div class="display">
        <v-tooltip top>
          <!-- eslint-disable-next-line vue/no-unused-vars -->
          <template v-slot:activator="{ on }">
            <p class="label" color="primary">Density</p>
            <!-- <span>in g/mL</span> -->
          </template>
        </v-tooltip>
        <p class="value">{{ element.density || "unknown" }}</p>
      </div>
      <template>
        <div :key="element.symbol" class="atomic-model">
          <chemical-element-visualisation :symbol="element.symbol.toLowerCase()"></chemical-element-visualisation>
        </div>
      </template>
      <v-tooltip bottom>
          <!-- eslint-disable-next-line vue/no-unused-vars -->
          <template v-slot:activator="{ on }">
                <div class="bohrOverlay"></div>
          </template>
        <!-- <span v-html="convertEC(element)"></span> -->
      </v-tooltip>
    </div>
  </div>
</template>

<script>
import General from "@/assets/elementGeneral.json";
import 'chemical-element-visualisation/chemical-element-visualisation.js';

export default {
  name: "InfoBox",
  props: ["element", "mass", "animations"],
  template: '#app-template',
  data() {
    return {
      atomGraph: null,
      general: General,
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
    };
  },
  // watch: {
    // element: function () {
    //   this.atomGraph.destroy();
    //   Object.assign(this.atomGraph, {
    //     numElectrons: this.element.atomicNumber,
    //     nucleusColor: this.classify(this.element)[3],
    //     electronColor: this.classify(this.element)[2],
    //     orbitalColor: this.classify(this.element)[3],
    //   });
    //   var orbitalRotationConfig = {
    //     pattern: {
    //       alternating: false,
    //       clockwise: false,
    //       preset: "cubedNegative",
    //     },
    //   };

    //   this.atomGraph._redrawAtom();
    //   if (this.animations) {
    //     this.atomGraph.rotateOrbitals(orbitalRotationConfig);
    //   }
    // },
  //   animations: function () {
  //     this.atomGraph.destroy();
  //     var orbitalRotationConfig = {
  //       pattern: {
  //         alternating: false,
  //         clockwise: false,
  //         preset: "cubedNegative",
  //       },
  //     };
  //     this.atomGraph._redrawAtom();
  //     if (this.animations) {
  //       this.atomGraph.rotateOrbitals(orbitalRotationConfig);
  //     }
  //   },
  // },
  // mounted() {
    // var atomicConfig = {
    //   containerId: "#bohr-model-container",
    //   numElectrons: this.element.atomicNumber,
    //   nucleusColor: this.classify(this.element)[3],
    //   electronRadius: 2.5,
    //   electronColor: this.classify(this.element)[2],
    //   orbitalWidth: 1,
    //   orbitalColor: this.classify(this.element)[3],
    //   idNumber: 10,
    //   animationTime: 0,
    //   orbitalRotationConfig: {
    //     pattern: {
    //       alternating: false,
    //       clockwise: false,
    //       preset: "cubedNegative",
    //     },
    //   },
    //   symbolOffset: 7,
    //   drawSymbol: true,
    // };
    // eslint-disable-next-line no-undef
    // this.atomGraph = new Atom(atomicConfig);
  // },
  methods: {
    classify(element) {
      var n = element.atomicNumber;
      if (this.nonMetal.includes(n)) {
        if ([7, 8].indexOf(n) > -1) {
          return [
            "Diatomic Nonmetal",
            "nonMetal",
            "rgba(91, 93, 153, 0.9)",
            "rgba(51, 53, 113, 1)",
          ];
        } else {
          return [
            "Polyatomic Nonmetal",
            "nonMetal",
            "rgba(86, 88, 148, 0.9)",
            "rgba(56, 58, 118, 1)",
          ];
        }
      } else if (this.alkali.includes(n)) {
        return [
          "Alkali Metal",
          "alkali",
          "rgba(120, 80, 90, 0.9)",
          "rgba(85, 45, 55, 1)",
        ];
      } else if (this.akaliEarth.includes(n)) {
        return [
          "Alkali Earth Metal",
          "alkaliEarth",
          "rgba(133, 113, 101, 0.9)",
          "rgba(83, 63, 51, 1)",
        ];
      } else if (this.transitionMetal.includes(n)) {
        return [
          "Transition Metal",
          "transitionMetal",
          "rgba(99, 113, 138, 0.9)",
          "rgba(54, 68, 93, 1)",
        ];
      } else if (this.postTransition.includes(n)) {
        return [
          "Post Transition Metal",
          "postTransition",
          "rgba(74, 134, 119, 0.9)",
          "rgba(34, 84, 79, 1)",
        ];
      } else if (this.halogen.includes(n)) {
        return [
          "Halogen",
          "halogen",
          "rgba(122, 120, 181, 0.9)",
          "rgba(57, 55, 106, 1)",
        ];
      } else if (this.noble.includes(n)) {
        return [
          "Noble Gas",
          "noble",
          "rgba(136, 100, 170, 0.9)",
          "rgba(76, 40, 110, 1)",
        ];
      } else if (this.lanthanoid.includes(n)) {
        return [
          "Lanthanoid",
          "lanthanoid",
          "rgba(120, 107, 151, 0.9)",
          "rgba(70, 57, 101, 1)",
        ];
      } else if (this.actinoid.includes(n)) {
        return [
          "Actinoid",
          "actinoid",
          "rgba(110, 89, 121, 0.9)",
          "rgba(62, 41, 73, 1)",
        ];
      } else if (this.metalloid.includes(n)) {
        return [
          "Metalloid",
          "metalloid",
          "rgba(74, 114, 146, 0.9)",
          "rgba(27, 67, 99, 1)",
        ];
      }
    },
    createState(state) {
      if (state === "solid") {
        return "Solid";
      } else if (state === "liquid") {
        return "Liquid";
      } else if (state === "gas") {
        return "Gas";
      } else {
        return "Unknown";
      }
    },
    // convertEC(element) {
    //   var ec = element.electronicConfiguration.split("");
    // //   var en = element.atomicNumber;
    //   for (var i = 0; i < ec.length; i++) {
    //     if (ec[i].match(/[a-z]/i) && i > 3) {
    //       ec[i + 1] = '<sup style="font-size: 10px">' + ec[i + 1] + "</sup>";
    //       if (ec[i + 2] && ec[i + 2] !== " ") {
    //         ec[i + 2] = '<sup style="font-size: 10px">' + ec[i + 2] + "</sup>";
    //         i++;
    //       }
    //       i++;
    //     }
    //   }
    //   if (parseInt(element.atomicNumber) > 2) {
    //     ec.splice(0, 0, '<span style="color: rgba(255, 255, 255, 0.5)">');
    //     ec.splice(5, 0, "</span>");
    //   }
    //   return ec.join("");
    // },
    getImg(state) {
      if (state === "solid") {
        return require("@/assets/solid.png");
      } else if (state === "liquid") {
        return require("@/assets/liquid.png");
      } else if (state === "gas") {
        return require("@/assets/gas.png");
      } else {
        return require("@/assets/unknown.png");
      }
    },
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
        92,
      ];
      if ((n <= 83 && n !== 61 && n !== 43) || exceptions.indexOf(n) > -1) {
        m = m.slice(0, -3);
        return parseFloat(m).toFixed(3);
      } else {
        return m.toString();
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.atomic-model {
  z-index: 0;
  position: absolute;
  margin-top: -6.2vw;
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
.box {
  width: 100%;
  height: 100%;
  padding-top: 0;
  padding-left: 3vw;
  .header {
    margin-left: 0.5vw;
    font-weight: 300;
    height: 5vw;
    line-height: 2vw;
    .classification {
      color: rgba(255, 255, 255, 0.5);
      font-size: 1.3vw;
      line-height: 1vw;
      font-weight: 400;
    }
    //TODO: refractor into object
    .alkali {
      color: rgba(192, 63, 95, 0.8);
    }
    .alkaliEarth {
      color: rgba(151, 103, 73, 0.8);
    }
    .transitionMetal {
      color: rgba(91, 113, 150, 0.8);
    }
    .noble {
      color: rgba(136, 92, 177, 0.8);
    }
    .halogen {
      color: rgba(122, 120, 202, 0.8);
    }
    .nonMetal {
      color: rgba(87, 91, 192, 0.8);
    }
    .metalloid {
      color: rgba(70, 134, 160, 0.8);
    }
    .postTransition {
      color: rgba(70, 153, 132, 0.8);
    }
    .lanthanoid {
      color: rgba(136, 109, 199, 0.8);
    }
    .actinoid {
      color: rgba(138, 81, 168, 0.8);
    }
    .name {
      color: rgba(255, 255, 255, 0.85);
      font-size: 2.1vw;
    }
  }
  .info {
    width: 100%;
    .state {
      width: 20%;
      margin-left: -5%;
      margin-right: -1%;
      display: block;
      float: left;
      position: relative;
      p {
        font-size: 1.3vw;
        color: rgba(255, 255, 255, 0.5);
        font-weight: 300;
        text-align: center;
        margin-bottom: 0;
        margin-top: 1.5vw;
      }
      img {
        width: 3vw;
        opacity: 0.7;
        left: 32.8%;
        margin-top: 0.7vw;
        position: absolute;
      }
    }
    .display {
      display: block;
      width: 25%;
      float: left;
      font-weight: 300;
      .label {
        font-size: 1.3vw;
        color: rgba(255, 255, 255, 0.5);
        text-align: center;
        margin-bottom: 0;
        margin-top: 1.5vw;
      }
      .value {
        font-size: 2.2vw;
        text-align: center;
        margin: 0.6vw auto 0 auto;
        color: rgba(255, 255, 255, 0.7);
      }
    }
    #ec {
      width: 56%;
      .value {
        margin-top: 0.5vw;
      }
    }
    #bohr-model-container {
      z-index: 0;
      position: absolute;
      margin-top: -9.2vw;
      margin-left: 26.5vw;
      width: 21vw;
      height: 21vw;
      float: right;
      .bohr-atomic-symbol {
        font-family: "Open Sans", sans-serif;
      }
    }
    .bohrOverlay {
      width: 10vw;
      height: 10vw;
      margin-left: 32vw;
      margin-top: -3.7vw;
      opacity: 0;
      position: absolute;
      z-index: 1;
    }
    .properties {
      float: left;
      margin-left: 1vw;
      text-align: center;
      width: 12vw;
    }
  }
}
@media only screen and (max-width: 600px) {
  .box {
    display: none;
  }
}
</style>
