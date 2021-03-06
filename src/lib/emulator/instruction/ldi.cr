require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class LDI < Opcode
    def call(cpu) : Bool
      target_reg = true
      target = Component::Reg8::Placeholder
      value = 0_u16

      case @args[0]
      when Component::Reg8
        target_reg = true
        target = @args[0].as(Component::Reg8)
      when Component::Reg16Mem
        target_reg = false
        target = cpu.ram.read16(cpu.reg.read(Component::Reg16.new(@args[0].as(Component::Reg16Mem).value)))
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      case @args[1]
      when Component::Reg8
        value = cpu.reg.read @args[1].as(Component::Reg8)
      when Component::Reg16Mem
        value = cpu.ram.read16(cpu.reg.read(Component::Reg16.new(@args[1].as(Component::Reg16Mem).value)))
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      if target_reg
        cpu.reg.write target.as(Component::Reg8), value.to_u8
      else
        if value >> 8 != 0
          cpu.ram.write16 target.as(UInt16), value.as(UInt16)
        else
          cpu.ram.write target.as(UInt16), value.as(UInt8)
        end
      end

      cpu.reg.inc Component::Reg16::HL

      true
    end
  end
end
