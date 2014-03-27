import unsigned, Testing

## A helper module containing procedures and templates for composing wrapped, unsigned integers

const debugging = true

template byte*(value : int) : uint8 =
  ## Convert an int value to a byte
  cast[uint8](value)

template byteWrapped(value : int) : int =
  ## Convert an int value to an int wrapped to byte range
  cast[int](cast[uint8](value))

template word*(byteA : int, byteB : int) : uint16 =
  ## Convert two int values wrapped to byte range into a word
  cast[uint16]((byteWrapped(byteB) shl 8) or byteWrapped(byteA))

template word*(byteA : uint8, byteB : uint8) : uint16 =
  ## Convert two bytes into a word
  cast[uint16]((cast[int](byteB) shl 8) or cast[int](byteA))

template word*(value : int) : uint16 =
  ## Convert an int value to a word
  cast[uint16](value)

testSuite("Byte testing"):
  test("Raw uint8"):
    var first, second : uint8 = 0
    first = 124
    second = 44

    message("Addition Check")
    assert(first + second == 168)
    assert(first + second == second + first)
    assert(first + second + second + second == 0)

    message("Subtraction Check")
    assert(first - second == 80)
    assert(second - first == 176)

    message("Multiplication Check")
    assert(first * second == 80)

    message("Negative Check")
    assert(first - 125 == 255)

  test("Byte templates"):
    var
      first : int = 1234
      second : int = 4321

    message("byte Check Const Literal")
    assert(byte(555) == 43)

    message("byte Check Runtime Variable")
    assert(byte(first) == 210)
    assert(byte(second) == 225)

    message("byteWrapped Check Const Literals")
    assert(byteWrapped(257) + 255 == 256)
    assert(6 == byteWrapped(3334))

    message("byteWrapped Check Runtime Variable")
    assert(byteWrapped(first) + 100 == 310)
    assert(byteWrapped(second) + 125 == 350)

  test("Raw uint16"):
    var first, second : uint16 = 0
    first = 65333
    second = 44431

    message("Addition check")
    assert(first + second == 44228)
    assert(first + second == second + first)
    assert(first + second + second == 23123)

    message("Subtraction Check")
    assert(first - second == 20902)
    assert(second - first == 44634)

    message("Multiplication Check")
    assert(first * second == 24475)

    assert(first - 65334 == 65535)

  test("Word templates"):
    var
      first : uint8 = 166 
      second : uint8 = byte(300) #44

    message("word Check Const Literal")
    assert(word(128, 33) == 0x2180)
    assert(word(128, 33) == 8576) #sanity check

    message("word Check Runtime Variable")
    assert(word(first, second) == 0x2CA6)

    message("word Check with Int Value")
    assert(word(65537) == 1)
    assert(word(65537 + 65539) == 4)

