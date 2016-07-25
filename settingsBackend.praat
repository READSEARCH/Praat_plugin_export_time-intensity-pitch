# To save settings we use separate files per setting.
# The setting files are stored in a settings/ subdirectory inside
# this script's directory (i.e. the plugin's directory) and they
# use a ".inf" file extension.

m_settingsDir$ = defaultDirectory$ + "/settings/"
m_settingsExt$ = ".inf"
;appendInfoLine: "Settings dir: ", m_settingsDir$

# Make sure the settings directory exists. Otherwise writeFile will fail.
@createDirectoryPath: m_settingsDir$

# Writes the provided number to the specified setting file.
procedure saveNumber: .settingName$, .settingValue
  writeFile: m_settingsDir$ + .settingName$  + m_settingsExt$, .settingValue
endproc

# Writes the provided string to the specified setting file.
procedure saveString: .settingName$, .settingValue$
  writeFile: m_settingsDir$ + .settingName$  + m_settingsExt$, .settingValue$
endproc

# Tries to read the number in the specified setting file.
# If the setting file exists the read number will be available as in the
# getNumber.result variable; if the setting file doesn't exist, the result
# variable will be set to 'undefined'
procedure getNumber: .settingName$
  .settingPath$ = m_settingsDir$ + .settingName$ + m_settingsExt$
  if fileReadable(.settingPath$)
    .result = readFile(.settingPath$)
  else
    .result = undefined
  endif
endproc

# Tries to read the string in the specified setting file.
# If the setting file exists the read string will be available as in the
# getString.result$ variable; if the setting file doesn't exits, the result
# variable will be set to the empty string.
procedure getString: .settingName$
  .settingPath$ = m_settingsDir$ + .settingName$ + m_settingsExt$
  if fileReadable(.settingPath$)
    .result$ = readFile$(.settingPath$)
  else
# --- TODO >>> Are there settings where an empty string is a valid value?
# --- TODO --- Maybe use a separate '.success' variable.
    # Note: You can't assign 'undefined' to a string (because it's a numeric
    # value. So we have to use an empty string instead.
    .result$ = ""
# --- TODO <<<
  endif
endproc

# Tries to create the provided directory using a system call.
# We need this because Praat's built-in 'createDirectory:' command doesn't
# seem to work if intermediate directories don't exist yet.
# Note that in contrast to the built-in 'createDirectory:' command, 'mkdir'
# seems to be sensitive to the type of slashes in the directory path. So
# we also need to make sure they are correct for the specific platform.
procedure createDirectoryPath: .directoryPath$
  if .directoryPath$ <> ""
    if windows == 1
      # Replace any forward slashes with backslashes on Windows.
      .directoryPath$ = replace$(.directoryPath$, "/", "\", 0)
      # On Windows 'mkdir' creates intermediate directories by default.
      runSystem: "mkdir """ + .directoryPath$ + """"
    else # macintosh or unix
      # Replace any forward slashes with backslashes on Unix-like platform.
      .directoryPath$ = replace$(.directoryPath$, "\", "/", 0)
      # On Macintosh and Unix we need to include the '-p' option to make sure
      # 'mkdir' also creates intermediate directories.
      runSystem: "mkdir -p """ + .directoryPath$ + """"
    endif
  endif
endproc

