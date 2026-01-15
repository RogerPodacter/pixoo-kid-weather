# Shared device discovery helpers for Pixoo scripts
module PixooDevice
  class NotFound < StandardError; end
  class NoneOnNetwork < StandardError; end
  class AmbiguousDevice < StandardError; end

  # Get device name (handles gem versions with/without accessor)
  def self.device_name(device)
    device.respond_to?(:name) ? device.name : device.instance_variable_get(:@name)
  end

  # Discover all devices on network
  def self.discover
    Pixoo::Client.find_all
  end

  # Find device by name (case-insensitive). Discovers automatically.
  # By default, waits and retries if device isn't found (it may be offline).
  # Set wait: false to fail immediately instead.
  def self.find_by_name(name, wait: true)
    waiting_shown = false

    loop do
      devices = discover

      if devices.any?
        match = devices.find { |d| device_name(d).to_s.casecmp?(name) }
        return match if match
      end

      # Device not found - error immediately if not waiting
      unless wait
        if devices.empty?
          raise NoneOnNetwork, "No Pixoo devices found on network!"
        else
          raise NotFound, "No device named \"#{name}\"\n\nAvailable:\n#{format_device_list(devices)}"
        end
      end

      # Wait and retry
      unless waiting_shown
        puts "Waiting for device \"#{name}\"..."
        waiting_shown = true
      end
      sleep 5
    end
  end

  # Resolve device by name. Auto-selects if only one device on network.
  # name: device name (can be nil to auto-select)
  # wait: if true, waits for device to come online (default: true)
  # Returns device, or raises AmbiguousDevice if multiple found without name
  def self.resolve(name, wait: true)
    name = name&.strip
    name = nil if name&.empty?

    if name.nil?
      waiting_shown = false
      loop do
        devices = discover
        return devices.first if devices.length == 1
        raise AmbiguousDevice, "Multiple devices found:\n#{format_device_list(devices)}" if devices.length > 1

        # No devices found
        raise NoneOnNetwork, "No Pixoo devices found on network!" unless wait

        unless waiting_shown
          puts "Waiting for device..."
          waiting_shown = true
        end
        sleep 5
      end
    else
      find_by_name(name, wait: wait)
    end
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

  # Ensure ImageMagick is installed (required for GIF generation)
  def self.require_imagemagick!
    has_magick = system("which magick > /dev/null 2>&1")
    has_convert = system("which convert > /dev/null 2>&1")

    unless has_magick || has_convert
      abort "Error: ImageMagick not found.\n\nInstall with: brew install imagemagick"
    end
  end

  # Get ImageMagick command (magick for v7, convert for v6)
  def self.imagemagick_command
    system("which magick > /dev/null 2>&1") ? "magick" : "convert"
  end
end
