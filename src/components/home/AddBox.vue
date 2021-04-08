<template>
	<div class="box">
		<!-- Exit button -->
		<v-btn depressed text class="exitButton">
			<v-icon block class="exitIcon" @click="exit()">close</v-icon>
		</v-btn>
		<!-- Display chemical formula -->
		<p class="addens">
			<span>{{equation }}</span>
		</p>
		<!-- Display atomic mass -->
		<p class="sum">
			<span v-html="compound"></span>= {{sum}}
		</p>
	</div>
</template>

<script>
export default {
	name: 'AddBox',
	props: ['elements', 'symbols'],
	data() {
		return {
			sum: this.elements[0],
			equation: this.elements[0],
			compound: this.symbols[0],
		};
	},
	watch: {
		//handle additional element added
		elements: function() {
			var equation = '';
			for (const element of this.elements) {
				equation += `${element} + `;
			}
			this.equation = equation.slice(0, -3);
			this.sum = parseFloat(this.elements.reduce((a, b) => a + b, 0).toFixed(3));
			var compoundObject = this.symbols.reduce(function(acc, symbol) {
				if (acc[symbol]) {
					acc[symbol]++;
				} else {
					acc[symbol] = 1;
				}
				return acc;
			}, {});
			var toArray = Object.entries(compoundObject);
			var toString = '';
			for (const [symbol, instances] of toArray) {
				if (instances > 1) {
					toString += `${symbol}<sub>${instances}</sub> `;
				} else {
					toString += `${symbol}`;
				}
			}
			this.compound = toString;
		},
	},
	methods: {
		exit() {
			this.$root.$emit('exitAddition', `Exited addition mode`);
		},
	},
};
</script>

<style lang="scss" scoped>
.box {
	width: 95.5%;
	height: 13.5vw;
	padding: 1.3vw;
	margin: auto;
	background: rgba(37, 43, 57, 1);
	position: relative;
	.exitButton {
		position: absolute;
		z-index: 9000;
		top: 0;
		border-radius: 0%;
		right: 0;
		width: 1.7vw;
		padding: 0;
		height: 1.7vw;
		opacity: 0.7;
		min-width: 0;
		margin: 0;
		.exitIcon {
			font-size: 1.5vw;
		}
	}
	.addens {
		font-size: 1.5vw;
		width: 100%;
		height: 7.3vw;
		overflow: hidden;
		margin: 0;
		margin-top: -0.3vw;
		font-weight: 300;
		opacity: 0.8;
	}
	.sum {
		height: 3.9vw;
		margin-top: 1vw;
		width: 100%;
		text-align: right;
		font-size: 2.5vw;
		opacity: 0.9;
		font-weight: 300;
		span {
			float: left;
			font-size: 1.5vw;
			line-height: 3.6vw;
			width: 30vw;
			height: 3.9vw;
			text-align: left;
			overflow: hidden;
		}
	}
}
</style>
