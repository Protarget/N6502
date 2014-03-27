import unsigned, SharedTemplates, Testing, Device

const debugging = true

## An memory-mapped device. A DeviceMap is created by composing devices, 
## each of which consume a fixed region of the processor's address space

type
  ## A sequential device map
  TDeviceMap* = object of TObject
    devices : seq[PDevice]

  PDeviceMap* = ref TDeviceMap

  TResolvedDevice = object
    device : PDevice
    address : int

proc newResolvedDevice(device : PDevice, address : int) : TResolvedDevice =
  ## Create a new resolved device consisting of a reference to the device and it's
  ## address in global memory space
  var resolvedAddress : TResolvedDevice
  resolvedAddress.device = device
  resolvedAddress.address = address
  return resolvedAddress

proc newDeviceMap*() : PDeviceMap =
  ## Create a new device map with empty address space
  var deviceMap : PDeviceMap
  deviceMap = new(TDeviceMap)
  deviceMap.devices = @[]
  return deviceMap

method addDevice*(self : PDeviceMap, device : PDevice) =
  ## Add a new device. This appends it into the address space
  ## and consumes len(device) addresses
  self.devices.add(device)

method resolveDevice(self : PDeviceMap, address : int) : TResolvedDevice =
  ## Resolve the device associated with a given address
  var index : int = 0
  for device in self.devices:
    if address < (index + device.len):
      return newResolvedDevice(device, index)
    index += device.len
  raise newException(EBase, "Unable to resolve " & $address & " to a device")

method write*(self : PDeviceMap, address : int, value : uint8) =
  ## Write an 8-bit value into the device map at address
  var resolvedDevice : TResolvedDevice = self.resolveDevice(address)
  resolvedDevice.device.write(address - resolvedDevice.address, value)

method read*(self : PDeviceMap, address : int) : uint8 =
  ## Read an 8-bit value from the device map at address
  var resolvedDevice : TResolvedDevice = self.resolveDevice(address)
  return resolvedDevice.device.read(address - resolvedDevice.address)

testSuite("Device Map Testing"):
  start:
    var deviceMap : PDeviceMap = newDeviceMap()

  test("Adding a device"):
    deviceMap.addDevice(newMemory(128))

  test("Addressing a single device"):
    deviceMap.addDevice(newMemory(128))
    message("Write Check")
    deviceMap.write(64, 120)
    message("Read Check")
    assert(deviceMap.read(64) == 120)

  test("Addressing multiple devices"):
    deviceMap.addDevice(newMemory(128))
    deviceMap.addDevice(newMemory(128))
    message("Write Check DeviceA")
    deviceMap.write(64, 120)
    message("Read Check DeviceA")
    assert(deviceMap.read(64) == 120)
    message("Write Check DeviceB")
    deviceMap.write(192, 60)  
    message("Read Check DeviceB")
    assert(deviceMap.read(192) == 60)
    message("Cross-device copy check")
    deviceMap.write(64, deviceMap.read(192))
    assert(deviceMap.read(64) == 60)

    deviceMap.addDevice(newMemory(128))
    message("One more device")
    deviceMap.write(320, 30)
    assert(deviceMap.read(320) == 30)


  test("Edge case tests"):
    var memory : PDevice = newMemory(128)
    var defaultDevice : PDevice = new(TDevice)
    deviceMap.addDevice(memory)
    deviceMap.addDevice(defaultDevice)
    message("Resolve test")
    assert(deviceMap.resolveDevice(127).device == memory)
    assert(deviceMap.resolveDevice(128).device == defaultDevice)