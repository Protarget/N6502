const runTests = true

template testSuite*(suiteNameBody : expr, body : stmt) : stmt {.immediate.} =
  block:
    var messageSequence : seq[string] = @[]

    template suiteName : expr {.immediate.} = suiteNameBody

    template runStart  {.immediate, dirty.} = nil
    template runFinish {.immediate, dirty.} = nil

    template start(startBody : stmt) {.immediate, dirty.} =
      template runStart : stmt {.immediate, dirty.} = startBody

    template finish(finishBody : stmt) {.immediate, dirty.} =
      template runFinish : stmt {.immediate, dirty.} = finishBody

    template message(text : string) : stmt {.immediate, dirty.} =
      bind messageSequence
      messageSequence.add(text)

    template outputMessages(indent : string) : stmt {.immediate, dirty.} =
      bind messageSequence
      for messageText in items(messageSequence):
        echo(indent & messageText)

    template test*(name : string, testBody : stmt) {.immediate, dirty.} =
      block:
        bind runTests, messageSequence
        messageSequence = @[]
        if runTests:
          try:
            runStart()
            testBody
          
          except:
            echo(suiteName & " | " & name & " failed: " & getCurrentExceptionMsg())
            outputMessages(suiteName & " | " & name & " message: ")

          finally:
            runFinish()

    body

testSuite("Sanity Testing"):

  start:
    var n : int = 32

  test("Literal Checks"):
    assert(1 == 1)
    message("Equal Check")
    assert(not (1 == 2))
    message("Not Equal Check")
    assert(1 + 1 == 2)
    message("Addition Check")

  test("Variable Checks"):
    assert(n == 32)
    message("Equal Check")
    assert(not (n == 16))
    message("Not Equal Check")
    assert(n / 2 == 16)
    message("Division Check")
