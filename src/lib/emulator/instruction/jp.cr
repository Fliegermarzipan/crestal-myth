require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class JP < Opcode
    def asminstr
      "JP"
    end

    def call(cpu) : Bool
      cond = true
      jmp = 0x0000_u16

      @args.each do |arg|
        case arg
        when DirectValue::SHORT
          jmp = cpu.ram.read16 cpu.reg.read Component::Reg16::PC
        when Component::Reg16Mem::HL
          jmp = cpu.ram.read16 cpu.reg.read Component::Reg16::HL
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

      cpu.reg.write Component::Reg16::PC, jmp if cond
      true
    end
  end
end
