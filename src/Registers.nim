import Testing, Unsigned

type
  TRegisters* = object
    a* : uint8
    x* : uint8
    y* : uint8
    pc* : uint16
    sp* : uint8
    p*: uint8

  PRegisters* = ref TRegisters

  TProcessorFlag* = enum
    carry = 1
    zero = 2
    interruptEnabled = 4
    decimalMode = 8
    interrupt = 16
    overflow = 64
    sign = 128

proc newRegisters*() : PRegisters =
  var registers : PRegisters = new(TRegisters)
  registers.a = 0
  registers.x = 0
  registers.y = 0
  registers.pc = 0
  registers.sp = 0
  registers.p = 0
  return registers

method setFlag(self : PRegisters, flag : TProcessorFlag, value : bool) =
  if value:
    self.p = self.p or cast[uint8](flag)
  else:
    self.p = self.p and (not cast[uint8](flag))

method getFlag(self : PRegisters, flag : TProcessorFlag) : bool =
  return cast[int]((self.p and cast[uint8](flag))) > 0

testSuite("Register Testing"):
  start:
    var registers : PRegisters = newRegisters()

  test("Register Sanity Check"):
    message("A Check")
    assert(registers.a == 0)
    message("X Check")
    assert(registers.x == 0)
    message("Y Check")
    assert(registers.y == 0)
    message("PC Check")
    assert(registers.pc == 0)
    message("SP Check")
    assert(registers.sp == 0)
    message("P Check")
    assert(registers.p == 0)

  test("Register Assignment Check"):
    message("A Check")
    registers.a = 32
    assert(registers.a == 32)
    message("X Check")
    registers.x = 32
    assert(registers.x == 32)
    message("Y Check")
    registers.y = 32
    assert(registers.y == 32)
    message("PC Check")
    registers.pc = 32
    assert(registers.pc == 32)
    message("SP Check")
    registers.sp = 32
    assert(registers.sp == 32)
    message("P Check")
    registers.p = 32
    assert(registers.p == 32)

  test("Register Flag Check"):
    registers.p = 0
    proc verifyExcept(registers : PRegisters, flag : TProcessorFlag, target : bool) =
      if flag != carry: assert(registers.getFlag(carry) == target)
      if flag != zero: assert(registers.getFlag(zero) == target)
      if flag != interruptEnabled: assert(registers.getFlag(interruptEnabled) == target)
      if flag != decimalMode: assert(registers.getFlag(decimalMode) == target)
      if flag != interrupt: assert(registers.getFlag(interrupt) == target)
      if flag != overflow: assert(registers.getFlag(overflow) == target)
      if flag != sign: assert(registers.getFlag(sign) == target)

    proc verify(registers : PRegisters, flag : TProcessorFlag) =
      registers.setFlag(flag, true)
      assert(registers.getFlag(flag) == true)
      verifyExcept(registers, flag, false)
      registers.setFlag(flag, false)
      assert(registers.getFlag(flag) == false)

    message("Carry Check")
    verify(registers, carry)
    message("Zero Check")
    verify(registers, zero)
    message("Interrupt Enabled Check")
    verify(registers, interruptEnabled)
    message("Decimal Mode Check")
    verify(registers, decimalMode)
    message("Interrupt Check")
    verify(registers, interrupt)
    message("Overflow Check")
    verify(registers, overflow)
    message("Sign Check")
    verify(registers, sign)