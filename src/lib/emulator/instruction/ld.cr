require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class LD < Opcode
    def call(cpu) : Bool
      target_reg = true
      target = Component::Reg8::Placeholder
      value = 0_u16

      case @args[0]
      when Component::Reg8, Component::Reg16
        target_reg = true
        target = @args[0].as(Component::Reg8 | Component::Reg16)
      when Component::Reg8Mem
        target_reg = false
        target = 0xFF00_u16 + cpu.reg.read(Component::Reg8.new(@args[0].as(Component::Reg8Mem).value))
      when Component::Reg16Mem
        target_reg = false
        target = cpu.reg.read(Component::Reg16.new(@args[0].as(Component::Reg16Mem).value))
      when DirectValueMem::SHORT
        target_reg = false
        target = cpu.ram.read16 cpu.reg.read Component::Reg16::PC
        cpu.reg.inc Component::Reg16::PC, 2
      when DirectValueMem::BYTE
        target_reg = false
        target = 0xFF00_u16 + cpu.ram.read cpu.reg.read Component::Reg16::PC
        cpu.reg.inc Component::Reg16::PC
      else
        Log.new.fatal "Unimplemented '#{disasm cpu}' with #{@args[0]} in first arg"
        return false
      end

      case @args[1]
      when Component::Reg8, Component::Reg16
        value = cpu.reg.read @args[1].as(Component::Reg8 | Component::Reg16)
      when Component::Reg8Mem
        value = cpu.ram.read(0xFF00_u16 + cpu.reg.read(Component::Reg8.new(@args[1].as(Component::Reg8Mem).value)))
      when Component::Reg16Mem
        value = cpu.ram.read(cpu.reg.read(Component::Reg16.new(@args[1].as(Component::Reg16Mem).value)))
      when DirectValue::SHORT
        value = cpu.ram.read16 cpu.reg.read Component::Reg16::PC
        cpu.reg.inc Component::Reg16::PC, 2
      when DirectValue::BYTE
        value = cpu.ram.read cpu.reg.read Component::Reg16::PC
        cpu.reg.inc Component::Reg16::PC
      else
        Log.new.fatal "Unimplemented '#{disasm cpu}' with #{@args[1]} in second arg"
        return false
      end

      if target_reg
        if target == Component::Reg8
          cpu.reg.write target.as(Component::Reg8), value.to_u8
        elsif target == Component::Reg16
          cpu.reg.write target.as(Component::Reg16), value.as(UInt16)
        end
      else
        if value >> 8 != 0
          cpu.ram.write16 target.as(UInt16), value.as(UInt16)
        else
          cpu.ram.write target.as(UInt16), value.as(UInt8)
        end
      end

      true
    end
  end
end
