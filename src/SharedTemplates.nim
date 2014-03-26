template debugLog*(text : string) : stmt =
  if debugging:
    echo text