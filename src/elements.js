//import periodic table dataset
var pt = require('periodic-table');

//data corrections
pt.elements.Helium.electronAffinity = '0';
pt.elements.Neon.electronAffinity = '0';
pt.elements.Argon.electronAffinity = '0';
pt.elements.Krypton.electronAffinity = '0';
pt.elements.Krypton.electronegativity = '3.0';
pt.elements.Xenon.electronAffinity = '0';
pt.elements.Xenon.electronegativity = '2.6';
pt.elements.Calcium.electronegativity = '1.0';
pt.elements.Radon.electronAffinity = '0';
pt.elements.Manganese.electronAffinity = '0';
pt.elements.Zinc.electronAffinity = '0';
pt.elements.Cadmium.electronAffinity = '0';
pt.elements.Mercury.electronAffinity = '0';
pt.elements.Mercury.electronegativity = '2.0';
pt.elements.Polonium.electronegativity = '2.0';
pt.elements.Hafnium.electronAffinity = '0';
pt.elements.Beryllium.electronAffinity = '0';
pt.elements.Magnesium.electronAffinity = '0';
pt.elements.Francium.meltingPoint = '300';

//convert atomic mass to standard atomic mass
pt.all().forEach(function(element) {
  var n = element.atomicNumber;
  var m = element.atomicMass;
  var exceptions = [57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 90, 91, 92];
  if ((n <= 83 && n !== 61 && n !== 43) || exceptions.indexOf(n) > -1) {
    m = m.slice(0, -3);
    element.atomicMass = parseFloat(m).toFixed(3);
    element.atomicMass = parseFloat(element.atomicMass);
  } else {
    element.atomicMass = parseFloat(m);
  }
});

export default pt.all();
