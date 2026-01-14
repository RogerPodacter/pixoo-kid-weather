# pixoo-kid-weather

<img width="250" src="https://github.com/user-attachments/assets/14f330a8-2ad9-4754-933c-6619d9959c7e" />

Kid-friendly displays for [Divoom Pixoo 64](https://divoom.com/products/pixoo-64) devices. Includes a weather dashboard with clothing suggestions, and a bedroom display with animated day/night cycle.

## Scripts

- **`scripts/weather`** - Weather + "what to wear" dashboard with optional morning countdown
- **`scripts/bedroom`** - Animated day/night cycle for kids' sleep schedule

## Setup

```bash
brew install imagemagick  # macOS (MiniMagick depends on it)
bundle install
cp .env.example .env      # then edit with your location and device names
```

### Device Discovery

Both scripts auto-discover Pixoo devices on your network. To see available devices:

```bash
scripts/weather --list
```

Use the device name (as set in the Divoom app) to target specific devices.

## Docker (Recommended for Pi)

```bash
cp .env.example .env     # edit with your location
docker compose up -d
```

Docker handles auto-restart on crash/reboot. To update:
```bash
scripts/update   # or: git pull && docker compose up --build -d
```

---

## Weather Display

Shows simple icons (sky + comfort), big clothing emojis, and an optional morning countdown bar.

### Layout

```
+------------------+
| Sky    | Comfort |
| icon   | icon    |
+--------+---------+
|                  |
|  Clothing emoji  |
|     (large)      |
|                  |
+------------------+
|   37° 10:55      |  <- parent info (tiny text)
+------------------+
|  [countdown bar] |  <- optional, configurable
+------------------+
```

- **Sky icon**: ☀️ 🌙 ☔ ❄️ ⛈️ ☁️ based on conditions
- **Comfort icon**: 😊 (nice) 🥶 (freezing) 🥵 (hot) 🌬️ (windy)
- **Clothing**: What to wear based on feels-like temp
- **Countdown bar**: Green→red timer for morning routine (optional)

### Clothing Logic

| Feels Like | Clothing |
|------------|----------|
| < 20°F     | 🧥 🧤 🧣 |
| 20-40°F    | 🧥 🧣 |
| 40-60°F    | 🧥 |
| 60-75°F    | 👕 |
| > 75°F     | 👕 🩳 😎 |

### Running

```bash
scripts/weather
```

Preview mode (no device needed):
```bash
scripts/weather --preview
```

### Configuration

| Variable | Description |
|----------|-------------|
| `LOCATION` | **Required.** City name or address (e.g., `Brooklyn, NY`) |
| `WEATHER_DEVICE` | Device name (optional if only one device) |
| `WEATHER_COUNTDOWN_START` | When countdown starts (e.g., `8:00am`) |
| `WEATHER_COUNTDOWN_END` | When countdown ends (e.g., `8:20am`) |

---

## Bedroom Display

Animated day/night cycle for kids' sleep schedule. Shows a starry night sky with heart constellation at bedtime, transitioning to a sunny day at wake time.

### Features

- Starry night with twinkling stars and heart constellation
- Smooth sunrise/sunset transitions with configurable fade duration
- Moon at night, sun during day
- Gradient sky that changes with time of day

### Running

Continuous mode:

```bash
scripts/bedroom
```

### Testing

Generate a transitions-focused GIF (recommended for testing):

```bash
scripts/bedroom --test-gif=transitions
open /tmp/pixoo_bedroom.gif
```

Generate a preview at a specific time:

```bash
scripts/bedroom --test-gif=8:30pm
scripts/bedroom --test-gif=sunset
open /tmp/pixoo_bedroom.gif
```

Generate a full 24-hour cycle (sparse transitions):

```bash
scripts/bedroom --test-gif=cycle
```

Demo mode (send frames to actual device):

```bash
scripts/bedroom --demo
```

### Configuration

| Variable | Description |
|----------|-------------|
| `LOCATION` | **Required.** City name or address (used for timezone) |
| `BEDROOM_DEVICE` | Device name (optional if only one device) |
| `BEDROOM_SUNSET` | When sunset starts (default: `7:30pm`) |
| `BEDROOM_NIGHT` | When fully night (default: `8:00pm`) |
| `BEDROOM_SUNRISE` | When sunrise starts (default: `6:30am`) |
| `BEDROOM_DAY` | When fully day (default: `7:00am`) |

**Example with defaults:**

- 7:30pm → Sunset begins, stars start appearing
- 8:00pm → Full starry night
- 6:30am → Sunrise begins
- 7:00am → Full daylight

---

## Notes

- Device discovery uses `Pixoo::Client.find_all` via UDP broadcast
- Emoji images are downloaded from Twemoji CDN on first use and cached in `/tmp`
- Weather data from [Open-Meteo API](https://open-meteo.com/) (no API key needed)
- Geocoding from [Nominatim/OpenStreetMap](https://nominatim.org/) (no API key needed)

## Dependencies

- Ruby 3.4.4
- [pixoo](https://github.com/tenderlove/pixoo-rb) gem for device communication
- ImageMagick for emoji resizing
- dotenv-rails for loading `.env` config
