import Processor, DeviceMap
import Instructions/NOP


proc newInstruction(name : string, index : int, width : uint16, addressing : PAddressingMode, fetching : PFetchingMode, behaviour : PBehaviour) : PInstruction =
  var result : PInstruction
  result = new(TInstruction)
  result.name = name
  result.index = index
  result.width = width
  result.addressing = addressing
  result.fetching = fetching
  result.behaviour = behaviour
  return result

proc fetchMemory(processor : PProcessor, address : uint16) : uint16 =
  return cast[uint16](processor.deviceMap.read(cast[int](address)))

proc fetchAddress(processor : PProcessor, address : uint16) : uint16 =
  return address
