require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class CALL < Opcode
    def asminstr
      "CALL"
    end

    def call(cpu) : Bool
      cond = true
      jmp = 0x0000_u16

      @args.each do |arg|
        case arg
        when DirectValue::SHORT
          jmp = cpu.ram.read16 cpu.reg.read Component::Reg16::PC
          cpu.reg.inc Component::Reg16::PC, 2
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
        end
      end

      if cond
        cpu.reg.dec Component::Reg16::SP, 2
        cpu.ram.write16 cpu.reg.read(Component::Reg16::SP), cpu.reg.read(Component::Reg16::PC)
        cpu.reg.write Component::Reg16::PC, jmp
      end
      true
    end
  end
end
