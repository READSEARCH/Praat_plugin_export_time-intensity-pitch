include settingsBackend.praat

# Read all the settings and use a default value if the setting
# doesn't exist yet.
@getString: "pitchAndIntensityOutputPath"
m_pitchAndIntensityOutputPath$ = getString.result$
if m_pitchAndIntensityOutputPath$ == ""
  m_pitchAndIntensityOutputPath$ = shellDirectory$ + "/WPP"
endif

@getNumber: "usePersonSubDir"
m_usePersonSubDir = getNumber.result
if m_usePersonSubDir <> 1
  m_usePersonSubDir = 0
endif

@getString: "personSeparator"
m_personSeparator$ = getString.result$
if m_personSeparator$ == ""
  m_personSeparator$ = "_"
endif

@getNumber: "showDebugOutput"
m_showDebugOutput = getNumber.result
if m_showDebugOutput <> 1
  m_showDebugOutput = 0
endif

@getNumber: "useAlternativeAlgorithm"
m_useAltAlgo = getNumber.result
if m_useAltAlgo <> 0
  m_useAltAlgo = 1
endif


# Show the settings window.
beginPause: "READSEARCH export sound data settings"
  comment: "There currently is no User Interface to set the pitch values,"
  comment: "this can be done in the code."
  comment: "The default values for the pitch contours are 75 to 500Hz."
  comment: "READSEARCH found values up to 650Hz when doing research in visual prosody."
  comment: ""
  sentence: "Output path", m_pitchAndIntensityOutputPath$
  boolean: "Group files in folders", m_usePersonSubDir
  word: "Group by words before", m_personSeparator$
  boolean: "Show debug output", m_showDebugOutput
  boolean: "Combine output to one file", m_useAltAlgo
m_settingsClicked = endPause: "Cancel", "OK", 2, 1

# Don't save anything if Cancel was clicked.
if m_settingsClicked == 1
  exitScript()
endif

# Sanitize the provided settings.
# Make sure the output path ends with a slash.
if not endsWith(output_path$, "/") and not endsWith(output_path$, "\")
  output_path$ = output_path$ + "/"
endif
# The person separator can't be empty, use the previous one instead.
if group_by_words_before$ == ""
  group_by_words_before$ = m_group_by_words_before$
  if m_showDebugOutput == 1
    appendInfoLine: "WARNING: Group symbol can't be empty using previous one instead."
  endif
endif

# Save the settings (if OK was clicked).
if m_settingsClicked == 2
  @saveString: "pitchAndIntensityOutputPath", output_path$
  @saveNumber: "usePersonSubDir", group_files_in_folders
  @saveString: "personSeparator", group_by_words_before$
  @saveNumber: "showDebugOutput", show_debug_output
  @saveNumber: "useAlternativeAlgorithm", combine_output_to_one_file
endif

