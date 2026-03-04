## Control Mapping Example
## 
## This example demonstrates parameter and value mapping utilities:
## - Parameter mapping with curves (linear, exponential, logarithmic, cubic)
## - MappedValue for range conversion and quantization
## - Practical use cases for synthesizer/audio parameters
##
## Shows how to map control inputs (knobs, CV) to musically useful ranges
## with appropriate scaling curves for natural feel.

import nimphea
import nimphea/hid/logger
import nimphea/hid/parameter
import nimphea/nimphea_mapped_value
import nimphea/nimphea_fixedstr
import math

useNimpheaNamespace()

var
  daisy: DaisySeed
  ledState: bool = false

proc demonstrateCurveTypes() =
  ## Show different curve types and their effect
  printLine("======================================")
  printLine("  Parameter Curve Types")
  printLine("======================================")
  printLine("")
  
  let testValues = [0.0'f32, 0.25'f32, 0.5'f32, 0.75'f32, 1.0'f32]
  
  # Linear mapping (direct proportion)
  printLine("Linear Curve (0-100):")
  for val in testValues:
    let mapped = mapParameter(val, 0.0, 100.0, LINEAR)
    printLine("  Input ", val, " -> ", mapped)
  printLine("")
  
  # Exponential curve (good for frequency)
  printLine("Exponential Curve (20-20000 Hz):")
  for val in testValues:
    let freq = mapParameter(val, 20.0, 20000.0, EXPONENTIAL)
    printLine("  Input ", val, " -> ", int(freq), " Hz")
  printLine("")
  
  # Logarithmic curve (good for volume)
  printLine("Logarithmic Curve (0-1 volume):")
  for val in testValues:
    let volume = mapParameter(val, 0.0, 1.0, LOGARITHMIC)
    printLine("  Input ", val, " -> ", volume)
  printLine("")
  
  # Cubic curve (smooth S-curve)
  printLine("Cubic Curve (0-100):")
  for val in testValues:
    let mapped = mapParameter(val, 0.0, 100.0, CUBE)
    printLine("  Input ", val, " -> ", mapped)
  printLine("")

proc demonstrateSynthParameters() =
  ## Realistic synthesizer parameter mappings
  printLine("======================================")
  printLine("  Synthesizer Parameter Mapping")
  printLine("======================================")
  printLine("")
  
  # Simulated knob positions (0.0 to 1.0)
  let cutoffKnob = 0.6'f32
  let resonanceKnob = 0.75'f32
  let attackKnob = 0.3'f32
  let octaveKnob = 0.4'f32
  let waveformKnob = 0.7'f32
  
  # Filter cutoff: 100 Hz to 10 kHz (exponential feels natural)
  let cutoffFreq = mapParameterExp(cutoffKnob, 100.0, 10000.0)
  printLine("Cutoff Knob at ", cutoffKnob, " -> ", int(cutoffFreq), " Hz (exponential)")
  
  # Resonance: 0 to 1 (linear is fine for resonance)
  let resonance = mapParameterLin(resonanceKnob, 0.0, 1.0)
  printLine("Resonance Knob at ", resonanceKnob, " -> ", resonance, " (linear)")
  
  # Envelope attack: 1ms to 5000ms (exponential for time feels good)
  let attackMs = mapParameterExp(attackKnob, 1.0, 5000.0)
  printLine("Attack Knob at ", attackKnob, " -> ", int(attackMs), " ms (exponential)")
  
  # Octave selection: -2 to +2 (quantized to discrete values)
  let octave = mapValueInt(octaveKnob, -2, 2)
  printLine("Octave Knob at ", octaveKnob, " -> ", octave, " octaves (quantized)")
  
  # Waveform selection: 0=Sine, 1=Saw, 2=Square, 3=Triangle
  let waveform = mapValueInt(waveformKnob, 0, 3)
  let waveNames = ["Sine", "Saw", "Square", "Triangle"]
  printLine("Waveform Knob at ", waveformKnob, " -> ", waveNames[waveform])
  printLine("")

proc demonstrateQuantization() =
  ## Show quantization for discrete parameters
  printLine("======================================")
  printLine("  Value Quantization")
  printLine("======================================")
  printLine("")
  
  # Quantize frequency to semitones
  printLine("Quantizing to semitones (12 steps/octave):")
  let baseFreq = 220.0'f32  # A3
  for knobVal in [0.0'f32, 0.2'f32, 0.5'f32, 0.8'f32, 1.0'f32]:
    let semitone = mapValueFloatQuantized(knobVal, 0.0, 12.0, 12)
    let freq = baseFreq * pow(2.0, semitone / 12.0)
    printLine("  Knob ", knobVal, " -> semitone ", int(semitone), " = ", int(freq), " Hz")
  printLine("")
  
  # Quantize mix to 10% increments
  printLine("Quantizing mix to 10% steps:")
  for knobVal in [0.23'f32, 0.47'f32, 0.68'f32, 0.95'f32]:
    let mixPercent = mapValueFloatQuantized(knobVal, 0.0, 100.0, 10)
    printLine("  Knob ", knobVal, " -> ", int(mixPercent), "%")
  printLine("")

proc demonstrateBipolarMapping() =
  ## Show bipolar CV/parameter mapping
  printLine("======================================")
  printLine("  Bipolar Parameter Mapping")
  printLine("======================================")
  printLine("")
  
  printLine("Pan control (center at 0.5):")
  for cvInput in [0.0'f32, 0.25'f32, 0.5'f32, 0.75'f32, 1.0'f32]:
    let pan = mapValueBipolar(cvInput, -1.0, 1.0)
    let position = if pan < -0.1: "Left"
                   elif pan > 0.1: "Right"
                   else: "Center"
    printLine("  CV ", cvInput, " -> Pan ", pan, " (", position, ")")
  printLine("")
  
  printLine("Pitch bend ±2 semitones (center at 0.5):")
  for cvInput in [0.0'f32, 0.5'f32, 1.0'f32]:
    let bendSemitones = mapValueBipolar(cvInput, -2.0, 2.0)
    printLine("  CV ", cvInput, " -> ", bendSemitones, " semitones")
  printLine("")

proc demonstrateNormalizationRoundtrip() =
  ## Show normalization and denormalization
  printLine("======================================")
  printLine("  Normalization Round-Trip")
  printLine("======================================")
  printLine("")
  
  let originalFreq = 440.0'f32
  let minFreq = 20.0'f32
  let maxFreq = 20000.0'f32
  
  # Normalize frequency to 0-1
  let normalized = normalizeValue(originalFreq, minFreq, maxFreq)
  printLine("Frequency ", int(originalFreq), " Hz in range ", int(minFreq), "-", int(maxFreq), " Hz")
  printLine("  -> Normalized: ", normalized)
  
  # Map back to frequency
  let restored = mapValueFloat(normalized, minFreq, maxFreq)
  printLine("  -> Restored: ", int(restored), " Hz")
  
  # Integer round-trip
  let originalOctave = 2
  let normOctave = normalizeValueInt(originalOctave, 0, 4)
  let restoredOctave = mapValueInt(normOctave, 0, 4)
  printLine("")
  printLine("Octave ", originalOctave, " in range 0-4")
  printLine("  -> Normalized: ", normOctave)
  printLine("  -> Restored: ", restoredOctave)
  printLine("")

proc demonstrateUtilityFunctions() =
  ## Show utility functions (lerp, clamp, etc.)
  printLine("======================================")
  printLine("  Utility Functions")
  printLine("======================================")
  printLine("")
  
  # Linear interpolation
  printLine("Lerp between 100 and 200:")
  for t in [0.0'f32, 0.25'f32, 0.5'f32, 0.75'f32, 1.0'f32]:
    let value = lerp(100.0, 200.0, t)
    printLine("  t=", t, " -> ", value)
  printLine("")
  
  # Inverse lerp
  printLine("Inverse lerp (find t for given value):")
  for value in [100.0'f32, 125.0'f32, 150.0'f32, 175.0'f32, 200.0'f32]:
    let t = inverseLerp(100.0, 200.0, value)
    printLine("  value=", value, " -> t=", t)
  printLine("")
  
  # Clamping
  printLine("Clamping values to range 0.0-1.0:")
  for value in [-0.5'f32, 0.0'f32, 0.5'f32, 1.0'f32, 1.5'f32]:
    let clamped = clamp(value, 0.0'f32, 1.0'f32)
    printLine("  value=", value, " -> clamped=", clamped)
  printLine("")
  
  # Quantization
  printLine("Quantize to 0.1 steps:")
  for value in [0.23'f32, 0.47'f32, 0.68'f32, 0.95'f32]:
    let quantized = quantizeFloat(value, 0.1)
    printLine("  value=", value, " -> quantized=", quantized)
  printLine("")

proc demonstrateDisplayFormatting() =
  ## Show using FixedStr with parameter values for display
  printLine("======================================")
  printLine("  Display Formatting")
  printLine("======================================")
  printLine("")
  
  var displayLine: FixedStr[32]
  
  # Filter display
  displayLine.init()
  discard displayLine.add("Cutoff: ")
  let cutoff = mapParameterExp(0.7, 100.0, 10000.0)
  discard displayLine.add(int(cutoff))
  discard displayLine.add(" Hz")
  printLine($displayLine)
  
  # Volume display
  displayLine.clear()
  discard displayLine.add("Vol: ")
  let volume = mapParameterLog(0.8, 0.0, 1.0)
  discard displayLine.add(int(volume * 100.0))
  discard displayLine.add("%")
  printLine($displayLine)
  
  # Waveform display
  displayLine.clear()
  discard displayLine.add("Wave: ")
  let waveIdx = mapValueInt(0.5, 0, 3)
  let waveName = case waveIdx
    of 0: "Sine"
    of 1: "Saw"
    of 2: "Square"
    else: "Triangle"
  discard displayLine.add(waveName)
  printLine($displayLine)
  
  printLine("")

proc main() =
  printLine("======================================")
  printLine("  Nimphea Control Mapping Demo")
  printLine("======================================")
  printLine("")
  
  # Initialize hardware
  daisy.init()
  startLog()
  
  # Run all demonstrations
  demonstrateCurveTypes()
  demonstrateSynthParameters()
  demonstrateQuantization()
  demonstrateBipolarMapping()
  demonstrateNormalizationRoundtrip()
  demonstrateUtilityFunctions()
  demonstrateDisplayFormatting()
  
  printLine("======================================")
  printLine("  Demo Complete - Blinking LED")
  printLine("======================================")
  printLine("")
  
  # Blink LED to show we're done
  while true:
    ledState = not ledState
    daisy.setLed(ledState)
    daisy.delay(500)

when isMainModule:
  main()
