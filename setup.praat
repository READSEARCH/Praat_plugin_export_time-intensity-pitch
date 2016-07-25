include settingsBackend.praat

# Add a READSEARCH-submenu for preferences to the Object window's Preferences menu
# item.
Add menu command: "Objects", "Preferences", "-- READSEARCH export sound data plugin --", "", 0, ""
Add menu command: "Objects", "Preferences", "READSEARCH export sound data plugin", "-- READSEARCH export sound data plugin --", 0, ""
Add menu command: "Objects", "Preferences", "Preferences...", "READSEARCH export sound data plugin", 1, "settingsWindow.praat"
Add menu command: "Objects", "Preferences", "About...", "READSEARCH export sound data plugin", 1, "about.praat"
# Add a READSEARCH export sound data command to the Object window's Goodies menu
# ite.
Add menu command: "Objects", "Goodies", "-- READSEARCH export sound data --", "", 0, ""
Add menu command: "Objects", "Goodies", "READSEARCH export sound data", "-- READSEARCH export sound data --", 0, "exportAll.praat"

# Note: Add menu command doesn't allow submenus for the SoundEditor (and
# probably other editor windows).
# Note: For some reason adding a separator doesn't seem to work in the
# SoundEditor's menu.
Add menu command: "SoundEditor", "File", "READSEARCH export sound data", "", 0, "pitchAndIntensity.praat"

# Initialise missing settings to their default value.
@getString: "pitchAndIntensityOutputPath"
if getString.result$ == ""
  @saveString: "pitchAndIntensityOutputPath", shellDirectory$ + "/_Sound_data/"
endif
@getNumber: "usePersonSubDir"
if getNumber.result <> 1
  @saveNumber: "usePersonSubDir", 0
endif
@getString: "personSeparator"
if getString.result$ == ""
  @saveString: "personSeparator", "-"
endif
@getNumber: "showDebugOutput"
if getNumber.result <> 1
  @saveNumber: "showDebugOutput", 0
endif

# We're now initialised.
@getNumber: "showDebugOutput"
if getNumber.result == 1
  appendInfoLine: "Initialised READSEARCH export sound data plugin"
endif

