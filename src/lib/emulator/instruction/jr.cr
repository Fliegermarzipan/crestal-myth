require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class JR < Opcode
    def call(cpu) : Bool
      cond = true
      jmp = 0x00_i8

      @args.each do |arg|
        case arg
        when DirectValue::BYTE
          jmp = cpu.ram.read(cpu.reg.read Component::Reg16::PC).to_i8
          cpu.reg.inc Component::Reg16::PC
        when Conditional::NZ
          cond = !cpu.reg.flag_read(Component::Flag::Z)
        when Conditional::Z
          cond = cpu.reg.flag_read(Component::Flag::Z)
        when Conditional::NC
          cond = !cpu.reg.flag_read(Component::Flag::C)
        when Conditional::C
          cond = cpu.reg.flag_read(Component::Flag::C)
        else
          Log.new.fatal "Unimplemented #{disasm cpu}"
          return false
        end
      end

      cpu.reg.write Component::Reg16::PC, cpu.reg.read(Component::Reg16::PC) + jmp if cond
      true
    end
  end
end
