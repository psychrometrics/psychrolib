// PsychroLib JavaScript example

var psychrolib = require('../../src/js/psychrolib.js')
// Set unit system - this needs to be done only once
psychrolib.SetUnitSystem(psychrolib.SI)
// Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
var TDewPoint = psychrolib.GetTDewPointFromRelHum(25.0, 0.80);
console.log('TDewPoint: %d degree C', TDewPoint);