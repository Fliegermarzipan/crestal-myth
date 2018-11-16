require "benchmark"
require "../constants"
require "../component/cpuregs"

module Crestal::Myth::Emulator
  enum DirectValue
    BYTE
    SHORT
  end

  class Opcode
    @code = 0_u8
    @cycles = 0
    @args = [] of Component::Reg8 | Component::Reg16 | Component::Reg16Mem | UInt16 | DirectValue
    @time : Time::Span

    def initialize(@code, @cycles, @args = [] of DirectValue)
      @time = CPU_CLOCK_TIME * @cycles
    end

    def asminstr
      "INVALID"
    end

    def disasm(cpu)
      ret = "#{asminstr}"
      @args.each do |arg|
        case typeof(arg)
        when Component::Reg8, Component::Reg16
          ret += " #{arg.to_s}"
        when Component::Reg16Mem
          ret += " (#{arg.to_s})"
        when UInt16
          ret += " ($#{arg})"
        when DirectValue
          case arg
          when DirectValue::BYTE
            ret += " $#{cpu.ram.read(cpu.reg.read(Component::Reg16::PC) + 1).to_s(16).rjust(2, '0')}"
          when DirectValue::SHORT
            ret += " $#{cpu.ram.read16(cpu.reg.read(Component::Reg16::PC) + 1).to_s(16).rjust(4, '0')}"
          end
        end
      end
      ret
    end

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
        Log.new.warn "Running late by #{t_delta.abs.nanoseconds}ns in #{disasm cpu}"
      end
      ret
    end
  end
end
