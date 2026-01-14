# Shared location/timezone helpers
module Location
  @cached_coords = nil
  @cached_timezone = nil

  def self.lat
    coords[:lat]
  end

  def self.lon
    coords[:lon]
  end

  def self.coords
    return @cached_coords if @cached_coords

    location = ENV["LOCATION"]
    unless location
      abort "Error: Set LOCATION in your .env file (e.g., 'Brooklyn, NY')"
    end

    @cached_coords = geocode_location(location)
  end

  def self.geocode_location(location)
    uri = URI("https://nominatim.openstreetmap.org/search")
    uri.query = URI.encode_www_form(q: location, format: "json", limit: 5)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "pixoo-weather (https://github.com/RogerPodacter/pixoo-kid-weather)"

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      abort "Error: Geocoding failed (HTTP #{response.code}). Try again later."
    end
    results = JSON.parse(response.body)

    if results.empty?
      abort "Error: Could not find location '#{location}'. Try a more specific name (e.g., 'Brooklyn, NY, USA')"
    end

    # Check for ambiguity - is there another high-importance result far away?
    if results.length > 1
      first = results.first
      first_importance = first["importance"] || 0

      # Only consider results with importance within 50% of the top result
      significant_results = results.select { |r| (r["importance"] || 0) > first_importance * 0.5 }

      ambiguous = significant_results[1..].any? do |r|
        distance_km(first["lat"].to_f, first["lon"].to_f, r["lat"].to_f, r["lon"].to_f) > 50
      end

      if ambiguous
        suggestions = significant_results.first(5).map { |r| "  - #{r['display_name']}" }
        abort "Error: '#{location}' is ambiguous. Did you mean:\n#{suggestions.join("\n")}"
      end
    end

    result = results.first
    puts "[Geocoding] Found: #{result['display_name']}"

    { lat: result["lat"].to_f, lon: result["lon"].to_f }
  end

  def self.distance_km(lat1, lon1, lat2, lon2)
    # Haversine formula for distance between two coordinates
    r = 6371 # Earth's radius in km
    dlat = (lat2 - lat1) * Math::PI / 180
    dlon = (lon2 - lon1) * Math::PI / 180
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1 * Math::PI / 180) * Math.cos(lat2 * Math::PI / 180) * Math.sin(dlon / 2)**2
    2 * r * Math.asin(Math.sqrt(a))
  end

  # Fetch and set timezone based on location coordinates
  def self.setup_timezone!
    return if @cached_timezone

    uri = URI("https://api.open-meteo.com/v1/forecast")
    uri.query = URI.encode_www_form(
      latitude: lat,
      longitude: lon,
      current: "temperature_2m",
      timezone: "auto"
    )

    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    @cached_timezone = data["timezone"]
    Time.zone = @cached_timezone
    puts "[Timezone] #{@cached_timezone}"
  end
end
