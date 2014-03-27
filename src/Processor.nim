import DeviceMap, Device, Registers, Tables, unsigned

type
  TProcessor* = object of TObject
    registers* : PRegisters
    deviceMap* : PDeviceMap
    instructionTable* : TTable[uint8, PInstruction]

  PProcessor* = ref TProcessor

  PAddressingMode* = ref proc(processor : PProcessor, argument : uint16) : uint16
  PFetchingMode* = ref proc(processor : PProcessor, argument : uint16) : uint16
  PBehaviour* = ref proc(processor : PProcessor, address : uint16) 

  TInstruction* = object #This has to be defined here because it has a recursive dependency on processor???
    index* : int
    width* : uint16
    name* : string
    addressing* : PAddressingMode
    fetching* : PFetchingMode
    behaviour* : PBehaviour

  PInstruction* = ref TInstruction

import Instruction