# Remember which objects were selected.
m = numberOfSelected()
for i from 1 to m
  initiallySelected[i] = selected(i)
endfor

# Check if the user selected any sound objects. If so, then only export
# those. If no sound objects were selected, then just try to export all
# sound objects in the Object window's list (if there are any).
n = numberOfSelected("Sound")
if n == 0
  select all
  n = numberOfSelected("Sound")
  # If there are still no sounds selected, this means there aren't any
  # sound objects in the object list of the Objects window. So we'll show
  # an error message to the user.
  if n == 0
    beginPause: "WPP Error"
      comment: "ERROR: No sound objects available to export."
    endPause: "OK", 1, 1
  endif
endif

# Only export the pitch and intensity data if sound objects are available.
if n > 0
  # Store the selected sound objects in an array.
  for i from 1 to n
    selectedSounds[i] = selected("Sound", i)
  endfor

  # Loop over the list of selected sound objects and export
  # their pitch and intensity data.
  for i from 1 to n
    selectObject: selectedSounds[i]
    View & Edit
    editor: selectedSounds[i]
      # Export the pitch and intensity data of the selected sound object.
      READSEARCH export sound data
      Close
    endeditor
  endfor
endif

# First deselect any selected objects.
selectObject()
# And then restore the intial selection.
for i from 1 to m
  plusObject: initiallySelected[i]
endfor

