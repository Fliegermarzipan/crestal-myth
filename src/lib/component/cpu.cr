require "./cpuregs"
require "../emulator/opcode"
require "../emulator/instruction/*"

module Crestal::Myth::Component
  class CPU
    @ops = StaticArray(Emulator::Opcode, 0xFF).new(Emulator::Opcode.new(0x00_u8, 0))

    def initialize(@ram : Memory)
      @log = Log.new
      @reg = CPURegs.new

      @reg.write Reg8::A, 0x01_u8
      @reg.write Reg8::F, 0xB0_u8
      @reg.write Reg16::BC, 0x0013_u16
      @reg.write Reg16::DE, 0x00D8_u16
      @reg.write Reg16::HL, 0x014D_u16
      @reg.write Reg16::SP, 0xFFFE_u16
      @reg.write Reg16::PC, 0x0100_u16

      seed_ops
    end

    def ram
      @ram
    end

    def reg
      @reg
    end

    def step
      addr = @reg.read Reg16::PC
      @reg.inc Reg16::PC
      opcode = @ram.read addr
      @log.debug "At 0x#{addr.to_s(16).rjust(4, '0')} (op 0x#{opcode.to_s(16).rjust(2, '0')}) - #{@ops[opcode].disasm(self)}"
      @ops[opcode].run self
    end

    def seed_ops
      @ops[0x00] = Emulator::Instruction::NOP.new 0x00_u8, 4
      @ops[0xc2] = Emulator::Instruction::JP.new 0xc2_u8, 12, [Emulator::Conditional::NZ] of Emulator::OpArgs
      @ops[0xc3] = Emulator::Instruction::JP.new 0xc3_u8, 12, [Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xca] = Emulator::Instruction::JP.new 0xca_u8, 12, [Emulator::Conditional::Z] of Emulator::OpArgs
      @ops[0xd2] = Emulator::Instruction::JP.new 0xd2_u8, 12, [Emulator::Conditional::NC] of Emulator::OpArgs
      @ops[0xda] = Emulator::Instruction::JP.new 0xda_u8, 12, [Emulator::Conditional::C] of Emulator::OpArgs
    end
  end
end
