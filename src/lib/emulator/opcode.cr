require "benchmark"
require "colorize"
require "../constants"
require "../component/cpuregs"

module Crestal::Myth::Emulator
  enum DirectValue
    BYTE
    SHORT
  end

  enum DirectValueMem
    BYTE
    SHORT
  end

  enum Conditional
    NZ
    Z
    NC
    C
  end

  alias OpArgs = Component::Reg8 | Component::Reg8Mem | Component::Reg16 | Component::Reg16Mem | Emulator::DirectValue | Emulator::DirectValueMem | Emulator::Conditional

  class Opcode
    @code = 0_u8
    @cycles = 0
    @args = [] of OpArgs
    @time : Time::Span
    @asminstr : String = "<INVALID>"

    macro inherited
      @asminstr = {{@type.stringify.split("::").last}}.ljust(4)
    end

    def initialize(@code, @cycles, @args = @args)
      @time = CPU_CLOCK_TIME * @cycles
    end

    def disasm(cpu)
      ret = "#{@asminstr} "
      @args.each.with_index do |arg, argi|
        case arg
        when Component::Reg8, Component::Reg16, Conditional
          ret += "#{arg.to_s}"
        when Component::Reg8Mem, Component::Reg16Mem
          ret += "(#{arg.to_s})"
        when DirectValue
          case arg
          when DirectValue::BYTE
            ret += "$#{cpu.ram.read(cpu.reg.read(Component::Reg16::PC)).to_s(16).rjust(2, '0')}"
          when DirectValue::SHORT
            ret += "$#{cpu.ram.read16(cpu.reg.read(Component::Reg16::PC)).to_s(16).rjust(4, '0')}"
          else
            Log.new.fatal "Impossible disassembly DirectValue #{arg}"
          end
        when DirectValueMem
          case arg
          when DirectValueMem::BYTE
            ret += "($#{cpu.ram.read(cpu.reg.read(Component::Reg16::PC)).to_s(16).rjust(2, '0')})"
          when DirectValueMem::SHORT
            ret += "($#{cpu.ram.read16(cpu.reg.read(Component::Reg16::PC)).to_s(16).rjust(4, '0')})"
          else
            Log.new.fatal "Impossible disassembly DirectValueMem #{arg}"
          end
        else
          Log.new.fatal "Impossible disassembly #{arg}"
        end
        if argi < @args.size - 1
          ret += ","
          ret = ret.ljust(ret.size + 7 - (ret.size % 7))
        end
      end
      ret.downcase.colorize(:red)
    end

    @[AlwaysInline]
    def call(cpu) : Bool
      false
    end

    def run(cpu) : Bool
      ret = false
      t_instr = Benchmark.realtime do
        ret = call cpu
      end
      t_delta = @time - t_instr
      if t_delta > 0.nanoseconds
        sleep t_delta
      else
        Log.new.warn "Last instruction ran late by #{t_delta.abs.nanoseconds.colorize(:yellow)}ns"
      end
      ret
    end
  end
end
