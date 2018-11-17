require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class RET < Opcode
    def call(cpu) : Bool
      cond = true

      @args.each do |arg|
        case arg
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

      if cond
        cpu.reg.write Component::Reg16::PC, cpu.ram.read16 cpu.reg.read Component::Reg16::SP
        cpu.reg.inc Component::Reg16::SP, 2
      end

      true
    end
  end
end
