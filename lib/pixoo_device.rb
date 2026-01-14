# Shared device discovery helpers for Pixoo scripts
module PixooDevice
  class NotFound < StandardError; end
  class NoneOnNetwork < StandardError; end

  # Get device name (handles gem versions with/without accessor)
  def self.device_name(device)
    device.respond_to?(:name) ? device.name : device.instance_variable_get(:@name)
  end

  # Discover all devices on network
  def self.discover
    Pixoo::Client.find_all
  end

  # Find device by name (case-insensitive). Discovers automatically.
  # Raises NotFound if name doesn't match, NoneOnNetwork if no devices found.
  def self.find_by_name(name)
    devices = discover
    raise NoneOnNetwork, "No Pixoo devices found on network!" if devices.empty?

    match = devices.find { |d| device_name(d).to_s.casecmp?(name) }
    return match if match

    raise NotFound, "No device named \"#{name}\"\n\nAvailable:\n#{format_device_list(devices)}"
  end

  # Format device list for display
  def self.format_device_list(devices)
    devices.map { |d| "  \"#{device_name(d)}\" (#{d.ip})" }.join("\n")
  end

  # List all discovered Pixoo devices
  def self.list_devices
    puts "Discovering Pixoo devices on the network..."
    devices = discover

    if devices.empty?
      puts "No Pixoo devices found!"
      puts "\nTroubleshooting tips:"
      puts "  - Ensure your Pixoo is powered on and connected to WiFi"
      puts "  - Ensure your computer is on the same network"
      puts "  - The Pixoo app should show the device as connected"
      return
    end

    puts "\nFound #{devices.length} device(s):\n"
    puts format_device_list(devices)
    puts "\nSet device name in .env:"
    puts "  WEATHER_DEVICE=\"Kitchen\""
    puts "  BEDROOM_DEVICE=\"Kids Room\""
    puts "\nDevice names are set in the Divoom app."
  end
end
