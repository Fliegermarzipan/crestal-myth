require "./lib/log"
require "./lib/cartridge"
require "./lib/gb"

# TODO: Write documentation for `Crestal::Myth`
module Crestal::Myth
  VERSION = "0.1.0"

  log = Log.new
  log.info("Starting Crestal::Myth")

  cart_path = "Tetris.gb" # TODO: Use app arguments
  log.debug "Reading #{cart_path} as cartridge"
  cart = Cartridge.new cart_path
  log.info "Cartridge name: #{cart.name}"
  log.debug "Cartridge code: #{cart.code}"
  log.debug "Cartridge type: #{cart.type}"

  gb = GB.new cart

  log.debug "Starting emulation"
  gb.run
end
