import unsigned, SharedTemplates, Testing

const debugging = true

## An memory-mapped device. A DeviceMap is created by composing devices, 
## each of which consume a fixed region of the processor's address space

type
  ## The base device
  TDevice = object of TObject
  PDevice = ref TDevice

  ## A basic RAM device
  TMemory* = object of TDevice
    memory : seq[uint8]
  PMemory* = ref TMemory

method write*(self : PDevice, address : int, value : uint8) =
  ## A method implemented by a device to define write behaviour.
  ## Address in the device's address space (0 = device's start location in main memory)
  debugLog("Default device write: " & $address & " = " & $value)

method read*(self : PDevice, address : int) : uint8 =
  ## A method implemented by a device to define read behaviour
  ## Address in the device's address space (0 = device's start location in main memory)
  debugLog("Default device read: " & $address)

method len*(self : PDevice) : int =
  ## A method implemented by a device to define it's length in memory
  return 1

proc newMemory(size : int) : PMemory =
  ## Create a new memory device of the specified size
  var device : PMemory = new(TMemory)
  device.memory = @[]
  for index in 0..(size - 1):
    device.memory.add(0)
  return device

method write*(self : PMemory, address : int, value : uint8) =
  ## Write a single byte into RAM at at the given address
  self.memory[address] = value

method read*(self : PMemory, address : int) : uint8 =
  ## Read a single byte from RAM
  return self.memory[address]

method len*(self : PMemory) : int =
  return self.memory.len

testSuite("Default Device Testing"):
  start:
    var device : PDevice = new(TDevice)

  test("Sanity Check"):
    assert(device != nil)
    assert(device.len == 1)
    assert(device.read(0) == 0)

testSuite("Memory Device Testing"):
  start:
    var device : PDevice = newMemory(65536)

  test("Initialization Check"):
    assert(device.len == 65536)
    for index in 0..65535:
      assert(device.read(index) == 0)

  test("Read/Write Check"):
    for index in 0..65535:
      device.write(index, 128)
      assert(device.read(index) == 128)
