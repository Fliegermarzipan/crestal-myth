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
      @ops[0xa8] = Emulator::Instruction::XOR.new 0xa8_u8, 4, [Reg8::B] of Emulator::OpArgs
      @ops[0xa9] = Emulator::Instruction::XOR.new 0xa9_u8, 4, [Reg8::C] of Emulator::OpArgs
      @ops[0xaa] = Emulator::Instruction::XOR.new 0xaa_u8, 4, [Reg8::D] of Emulator::OpArgs
      @ops[0xab] = Emulator::Instruction::XOR.new 0xab_u8, 4, [Reg8::E] of Emulator::OpArgs
      @ops[0xac] = Emulator::Instruction::XOR.new 0xac_u8, 4, [Reg8::H] of Emulator::OpArgs
      @ops[0xad] = Emulator::Instruction::XOR.new 0xad_u8, 4, [Reg8::L] of Emulator::OpArgs
      @ops[0xae] = Emulator::Instruction::XOR.new 0xae_u8, 8, [Reg16Mem::HL] of Emulator::OpArgs
      @ops[0xaf] = Emulator::Instruction::XOR.new 0xaf_u8, 4, [Reg8::A] of Emulator::OpArgs
      @ops[0xc2] = Emulator::Instruction::JP.new 0xc2_u8, 12, [Emulator::Conditional::NZ] of Emulator::OpArgs
      @ops[0xc3] = Emulator::Instruction::JP.new 0xc3_u8, 12, [Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xc4] = Emulator::Instruction::CALL.new 0xc4_u8, 12, [Emulator::Conditional::NZ, Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xca] = Emulator::Instruction::JP.new 0xca_u8, 12, [Emulator::Conditional::Z] of Emulator::OpArgs
      @ops[0xcc] = Emulator::Instruction::CALL.new 0xcc_u8, 12, [Emulator::Conditional::Z, Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xcd] = Emulator::Instruction::CALL.new 0xcd_u8, 12, [Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xd2] = Emulator::Instruction::JP.new 0xd2_u8, 12, [Emulator::Conditional::NC] of Emulator::OpArgs
      @ops[0xd4] = Emulator::Instruction::CALL.new 0xd4_u8, 12, [Emulator::Conditional::NC, Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xda] = Emulator::Instruction::JP.new 0xda_u8, 12, [Emulator::Conditional::C] of Emulator::OpArgs
      @ops[0xdc] = Emulator::Instruction::CALL.new 0xdc_u8, 12, [Emulator::Conditional::C, Emulator::DirectValue::SHORT] of Emulator::OpArgs
      @ops[0xee] = Emulator::Instruction::XOR.new 0xee_u8, 8, [Emulator::DirectValue::BYTE] of Emulator::OpArgs
    end
  end
end
