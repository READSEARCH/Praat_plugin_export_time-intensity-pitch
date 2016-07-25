include settingsBackend.praat

@getNumber: "showDebugOutput"
m_showDebugOutput = getNumber.result

# Retrieve some properties of the sound from its info.
m_soundInfo$ = Sound info
m_outputName$ = extractLine$(m_soundInfo$, "Object name: ")
m_soundStartTime = extractNumber(m_soundInfo$, "Start time: ")
m_soundEndTime = extractNumber(m_soundInfo$, "End time: ")

# Get the output path from the settings. And if no valid path has been set,
# show an appropriate error message.
@getString: "pitchAndIntensityOutputPath"
m_outputPath$ = getString.result$
if m_outputPath$ == ""
  beginPause: "WPP Error"
    comment: "ERROR: No (or invalid) output path set."
    comment: "Please set a valid output path in the WPP preferences:"
    if windows
      comment: tab$ + "Objects Window > Praat > Preferences > WPP > Preferences..."
    else
      comment: tab$ + "Praat > Preferences > WPP > Preferences..."
    endif
  endPause: "OK", 1, 1
  exitScript()
endif

# Check if the subdirectory-per-person feature is enabled. And if so, append
# the correct subdirectory to the output path.
@getNumber: "usePersonSubDir"
m_usePersonSubDir = getNumber.result
if m_usePersonSubDir
  m_subDirName$ = m_outputName$
  @getString: "personSeparator"
  m_personSeparator$ = getString.result$
  m_separatorIdx = index(m_outputName$, m_personSeparator$)
  # If the separator was found, extract the part before it and use that
  # for the subdirectory's name. Otherwise just use the whole name for
  # the subdirectory.
  # Note: If the separator would be the first character we also just use
  # the whole name.
  if m_separatorIdx > 1
    m_subDirName$ = left$(m_outputName$, m_separatorIdx - 1)
  endif
  m_outputPath$ = m_outputPath$ + m_subDirName$ + "/"
endif

if m_showDebugOutput == 1
  appendInfoLine: "Using output path: ", m_outputPath$
endif

# If nothing was selected, select the whole sound.
# Also if something was selected, we'll append the selection's start
# time to the name used for the output file. We do this to make sure
# a different filename is used in case the user wants to export different
# parts of the same sound object.
m_orgSelectionLength = Get selection length
if m_orgSelectionLength == 0
  # Store the current cursor position, so we can restore it at the end.
  m_orgCursorPos = Get cursor
  # Select the whole sound.
  Select: m_soundStartTime, m_soundEndTime
else
  # If there already was a selection, append the selection's start time
  # to the name for the output file.
  m_selectionStartTime = Get start of selection
  m_outputName$ = m_outputName$ + "[" + fixed$(m_selectionStartTime, 3) + "]"
endif

# Make sure the output path exists:
@createDirectoryPath: m_outputPath$


# Check whether or not to use the built-in pitch & intensity calculations
# or if we should use the custom/alternative approach.
@getNumber: "useAlternativeAlgorithm"
m_useAltAlgo = getNumber.result
if m_useAltAlgo <> 1
  if m_showDebugOutput == 1
    appendInfoLine: "Using built-in pitch & intensity calculations."
  endif

  ## Pitch
  # Show the pitch contour if it wasn't shown yet. And also remember if it
  # was or wasn't, so we can restore it to the correct status later on.
  @showPitchIfNotVisible
  m_pitchContourWasVisible = showPitchIfNotVisible.result

  m_listing$ = Pitch listing
  # Make the values in m_listing$ tab separated instead of "tripple space"
  # separated.
  # Note: The regular expression of " 3" will only match 3 consecutive spaces.
  # In case the format of 'Pitch listing' is prone to changes, a less specific
  # regular expression of e.g. " +" or " {2,}" might be preferred.
  m_listing$ = replace_regex$(m_listing$, " {3}", "\t", 0)
  m_outputFile$ = m_outputPath$ + m_outputName$ + "_pitch.txt"
  writeFile: m_outputFile$, m_listing$
  if m_showDebugOutput == 1
    appendInfoLine: "Wrote pitch listing to: ", m_outputFile$
  endif

  # Hide the pitch contour again if it wasn't visible before.
  if m_pitchContourWasVisible == 0
    Show pitch
  endif

  ## Intensity
  # Show the intensity contour if it wasn't shown yet and remeber if it was or wasn't.
  @showIntensityIfNotVisible
  m_intensityContourWasVisible = showIntensityIfNotVisible.result
  m_listing$ = Intensity listing
  m_listing$ = replace_regex$(m_listing$, " {3}", "\t", 0)
  m_outputFile$ = m_outputPath$ + m_outputName$ + "_intensity.txt"
  writeFile: m_outputFile$, m_listing$
  if m_showDebugOutput == 1
    appendInfoLine: "Wrote intensity listing to: ", m_outputFile$
  endif

  # Hide the intensity contour again if it wasn't visible.
  if m_intensityContourWasVisible == 0
    Show intensity
  endif
else
  if m_showDebugOutput == 1
    appendInfoLine: "Using alternative pitch & intensity calculations."
  endif

  m_tmin = Get start of selection
  m_tmax = Get end of selection

  # Currently the sound object (should be/)is selected. Creating the
  # pitch & intensity objects will cause it to get deselected. So keep
  # track of it, so we can reselect it later on.
  if numberOfSelected("Sound") > 0
    m_selectedSoundObj = selected("Sound")
  else
    beginPause: "WPP Error"
      comment: "ERROR: No sound object selected."
      comment: "Please make sure the sound object is selected when using the alternative algorithm to calculate the pitch & intensity.
    endPause: "OK", 1, 1
    exitScript()
  endif

  m_outputFile$ = m_outputPath$ + m_outputName$ + ".txt"

  # We need to leave the editor window and go back to the Objects window
  # for "To Pitch" and "To Intensity" to work.
  endeditor

  m_pitchObj = To Pitch: 0.01, 75, 650
  selectObject: m_selectedSoundObj
  # Set last parameter to 0 if you don't want to subtract the mean pressure.
  m_intensityObj = To Intensity: 75, 0.001, 1

  # Make sure the output file is "empty" before we append to it.
  # Note: Another option would be to use writeFileLine the first time
  # we loop, and then appendInfoLine.
  deleteFile: m_outputFile$

  for i to (m_tmax-m_tmin)/0.01
    m_time = m_tmin + i * 0.01
    selectObject: m_pitchObj
    m_pitch = Get value at time: m_time, "Hertz", "Linear"
    selectObject: m_intensityObj
    m_intensity = Get value at time: m_time, "Cubic"
    appendFileLine: m_outputFile$, fixed$(m_time, 3), tab$, fixed$(m_intensity, 3), tab$, fixed$(m_pitch, 3)
  endfor
  removeObject: m_pitchObj, m_intensityObj
  selectObject: m_selectedSoundObj

  # Move back to the editor window.
  editor
endif

# Restore the cursor position if the user didn't select anything.
if m_orgSelectionLength == 0
  Move cursor to: m_orgCursorPos
endif


### Procedures ###

# This uses a detour to see if the pitch contour is visible
# I.e. if the pitch contour isn't yet visible the "Get pitch" command
# will fail and won't return a value. So if the return value is still
# 'undefined' after the command finished, we know the contour wasn't
# yet visible
# @return '.result' will be 1 if the pitch contour was already visible,
# 0 if it wasn't.
procedure showPitchIfNotVisible
  # Note: We have to use 'nocheck' to prevent the error popup that
  # normally would show up when using "Get pitch" when no contour
  # is showing yet.
  .tmpVal = nocheck Get pitch
  .result = 1
  if .tmpVal == undefined
    Show pitch
    .result = 0
  endif
endproc

# This uses a detour to see if the intensity contour is visible
# I.e. if the intensity contour isn't yet visible the "Get intensity"
# command will fail and won't return a value. So if the return value
# is still 'undefined' after the command finished, we know the contour
# wasn't yet visible
# @return '.result' will be 1 if the intensity contour was already
# visible, 0 if it wasn't.
procedure showIntensityIfNotVisible
  # Note: We have to use 'nocheck' to prevent the error popup that
  # normally would show up when using "Get intensity" when no contour
  # is showing yet.
  .tmpVal = nocheck Get intensity
  .result = 1
  if .tmpVal == undefined
    Show intensity
    .result = 0
  endif
endproc
 
