require "./cpuregs"
require "../emulator/opcode"
require "../emulator/instruction/*"

module Crestal::Myth::Component
  class CPU
    @ops = StaticArray(Emulator::Opcode, 0x100).new(Emulator::Opcode.new(0x00_u8, 0))

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

      @log.debug "Loading opcodes"
      seed_ops
      @log.debug "CPU initialized"
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

    macro gen_op(name, op, time, args)
      @ops[{{op}}] = Emulator::Instruction::{{name}}.new {{op}}_u8, {{time}}, {{args.id}} of Emulator::OpArgs
    end

    def seed_ops
      gen_op NOP, 0x00, 4, "[]" # crystal macro bug workaround

      gen_op XOR, 0xa8, 4, [Reg8::B]
      gen_op XOR, 0xa9, 4, [Reg8::C]
      gen_op XOR, 0xaa, 4, [Reg8::D]
      gen_op XOR, 0xab, 4, [Reg8::E]
      gen_op XOR, 0xac, 4, [Reg8::H]
      gen_op XOR, 0xad, 4, [Reg8::L]
      gen_op XOR, 0xae, 8, [Reg16Mem::HL]
      gen_op XOR, 0xaf, 4, [Reg8::A]
      gen_op XOR, 0xee, 8, [Emulator::DirectValue::BYTE]

      gen_op JP, 0xc2, 12, [Emulator::Conditional::NZ]
      gen_op JP, 0xc3, 12, [Emulator::DirectValue::SHORT]
      gen_op JP, 0xca, 12, [Emulator::Conditional::Z]
      gen_op JP, 0xd2, 12, [Emulator::Conditional::NC]
      gen_op JP, 0xda, 12, [Emulator::Conditional::C]

      gen_op CALL, 0xc4, 12, [Emulator::Conditional::NZ, Emulator::DirectValue::SHORT]
      gen_op CALL, 0xcc, 12, [Emulator::Conditional::Z, Emulator::DirectValue::SHORT]
      gen_op CALL, 0xcd, 12, [Emulator::DirectValue::SHORT]
      gen_op CALL, 0xd4, 12, [Emulator::Conditional::NC, Emulator::DirectValue::SHORT]
      gen_op CALL, 0xdc, 12, [Emulator::Conditional::C, Emulator::DirectValue::SHORT]

      gen_op LD, 0x01, 12, [Reg16::BC, Emulator::DirectValue::SHORT]
      gen_op LD, 0x02, 8, [Reg16Mem::BC, Reg8::A]
      gen_op LD, 0x06, 8, [Reg8::B, Emulator::DirectValue::BYTE]
      gen_op LD, 0x08, 20, [Emulator::DirectValueMem::SHORT, Reg16::SP]
      gen_op LD, 0x0a, 8, [Reg8::A, Reg16Mem::BC]
      gen_op LD, 0x0e, 8, [Reg8::C, Emulator::DirectValue::BYTE]
      gen_op LD, 0x11, 12, [Reg16::DE, Emulator::DirectValue::SHORT]
      gen_op LD, 0x12, 8, [Reg16Mem::DE, Reg8::A]
      gen_op LD, 0x16, 8, [Reg8::D, Emulator::DirectValue::BYTE]
      gen_op LD, 0x1a, 8, [Reg8::A, Reg16Mem::DE]
      gen_op LD, 0x1e, 8, [Reg8::E, Emulator::DirectValue::BYTE]
      gen_op LD, 0x21, 12, [Reg16::HL, Emulator::DirectValue::SHORT]
      gen_op LD, 0x26, 8, [Reg8::H, Emulator::DirectValue::BYTE]
      gen_op LD, 0x2e, 8, [Reg8::L, Emulator::DirectValue::BYTE]
      gen_op LD, 0x31, 12, [Reg16::SP, Emulator::DirectValue::SHORT]
      gen_op LD, 0x36, 12, [Reg16Mem::HL, Emulator::DirectValue::BYTE]
      gen_op LD, 0x3e, 8, [Reg8::A, Emulator::DirectValue::BYTE]
      gen_op LD, 0x40, 4, [Reg8::B, Reg8::B]
      gen_op LD, 0x41, 4, [Reg8::B, Reg8::C]
      gen_op LD, 0x42, 4, [Reg8::B, Reg8::D]
      gen_op LD, 0x43, 4, [Reg8::B, Reg8::E]
      gen_op LD, 0x44, 4, [Reg8::B, Reg8::H]
      gen_op LD, 0x45, 4, [Reg8::B, Reg8::L]
      gen_op LD, 0x46, 8, [Reg8::B, Reg16Mem::HL]
      gen_op LD, 0x47, 4, [Reg8::B, Reg8::A]
      gen_op LD, 0x48, 4, [Reg8::C, Reg8::B]
      gen_op LD, 0x49, 4, [Reg8::C, Reg8::C]
      gen_op LD, 0x4a, 4, [Reg8::C, Reg8::D]
      gen_op LD, 0x4b, 4, [Reg8::C, Reg8::E]
      gen_op LD, 0x4c, 4, [Reg8::C, Reg8::H]
      gen_op LD, 0x4d, 4, [Reg8::C, Reg8::L]
      gen_op LD, 0x4e, 8, [Reg8::C, Reg16Mem::HL]
      gen_op LD, 0x4f, 4, [Reg8::C, Reg8::A]
      gen_op LD, 0x50, 4, [Reg8::D, Reg8::B]
      gen_op LD, 0x51, 4, [Reg8::D, Reg8::C]
      gen_op LD, 0x52, 4, [Reg8::D, Reg8::D]
      gen_op LD, 0x53, 4, [Reg8::D, Reg8::E]
      gen_op LD, 0x54, 4, [Reg8::D, Reg8::H]
      gen_op LD, 0x55, 4, [Reg8::D, Reg8::L]
      gen_op LD, 0x56, 8, [Reg8::D, Reg16Mem::HL]
      gen_op LD, 0x57, 4, [Reg8::D, Reg8::A]
      gen_op LD, 0x58, 4, [Reg8::E, Reg8::B]
      gen_op LD, 0x59, 4, [Reg8::E, Reg8::C]
      gen_op LD, 0x5a, 4, [Reg8::E, Reg8::D]
      gen_op LD, 0x5b, 4, [Reg8::E, Reg8::E]
      gen_op LD, 0x5c, 4, [Reg8::E, Reg8::H]
      gen_op LD, 0x5d, 4, [Reg8::E, Reg8::L]
      gen_op LD, 0x5f, 4, [Reg8::E, Reg8::A]
      gen_op LD, 0x5e, 8, [Reg8::E, Reg16Mem::HL]
      gen_op LD, 0x60, 4, [Reg8::H, Reg8::B]
      gen_op LD, 0x61, 4, [Reg8::H, Reg8::C]
      gen_op LD, 0x62, 4, [Reg8::H, Reg8::D]
      gen_op LD, 0x63, 4, [Reg8::H, Reg8::E]
      gen_op LD, 0x64, 4, [Reg8::H, Reg8::H]
      gen_op LD, 0x65, 4, [Reg8::H, Reg8::L]
      gen_op LD, 0x66, 8, [Reg8::H, Reg16Mem::HL]
      gen_op LD, 0x67, 4, [Reg8::H, Reg8::A]
      gen_op LD, 0x68, 4, [Reg8::L, Reg8::B]
      gen_op LD, 0x69, 4, [Reg8::L, Reg8::C]
      gen_op LD, 0x6a, 4, [Reg8::L, Reg8::D]
      gen_op LD, 0x6b, 4, [Reg8::L, Reg8::E]
      gen_op LD, 0x6c, 4, [Reg8::L, Reg8::H]
      gen_op LD, 0x6d, 4, [Reg8::L, Reg8::L]
      gen_op LD, 0x6e, 8, [Reg8::L, Reg16Mem::HL]
      gen_op LD, 0x6f, 4, [Reg8::L, Reg8::A]
      gen_op LD, 0x70, 8, [Reg16Mem::HL, Reg8::B]
      gen_op LD, 0x71, 8, [Reg16Mem::HL, Reg8::C]
      gen_op LD, 0x72, 8, [Reg16Mem::HL, Reg8::D]
      gen_op LD, 0x73, 8, [Reg16Mem::HL, Reg8::E]
      gen_op LD, 0x74, 8, [Reg16Mem::HL, Reg8::H]
      gen_op LD, 0x75, 8, [Reg16Mem::HL, Reg8::L]
      gen_op LD, 0x77, 8, [Reg16Mem::HL, Reg8::A]
      gen_op LD, 0x78, 4, [Reg8::A, Reg8::B]
      gen_op LD, 0x79, 4, [Reg8::A, Reg8::C]
      gen_op LD, 0x7a, 4, [Reg8::A, Reg8::D]
      gen_op LD, 0x7b, 4, [Reg8::A, Reg8::E]
      gen_op LD, 0x7c, 4, [Reg8::A, Reg8::H]
      gen_op LD, 0x7d, 4, [Reg8::A, Reg8::L]
      gen_op LD, 0x7e, 8, [Reg8::A, Reg16Mem::HL]
      gen_op LD, 0x7f, 4, [Reg8::A, Reg8::A]
      gen_op LD, 0xe0, 12, [Emulator::DirectValueMem::BYTE, Reg8::A]
      gen_op LD, 0xe2, 8, [Reg8Mem::C, Reg8::A]
      gen_op LD, 0xea, 16, [Emulator::DirectValueMem::SHORT, Reg8::A]
      gen_op LD, 0xf0, 12, [Reg8::A, Emulator::DirectValueMem::BYTE]
      gen_op LD, 0xf2, 8, [Reg8::A, Reg8Mem::C]
      gen_op LD, 0xfa, 16, [Reg8::A, Emulator::DirectValueMem::SHORT]
      gen_op LD, 0xf9, 8, [Reg16::SP, Reg16::HL]

      gen_op LDD, 0x32, 8, [Reg16Mem::HL, Reg8::A]
      gen_op LDD, 0x3a, 8, [Reg8::A, Reg16Mem::HL]
    end
  end
end
