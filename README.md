# pixoo-kid-weather

<img width="250" src="https://github.com/user-attachments/assets/14f330a8-2ad9-4754-933c-6619d9959c7e" />

Kid-friendly weather + "what to wear" dashboard for a [Divoom Pixoo 64](https://divoom.com/products/pixoo-64). It shows simple icons (sky + comfort), big clothing emojis, and an optional morning countdown bar.

You'll need a Pixoo 64 on your local network. Just plug it in and run the script—device detection is automatic.

## Display Layout

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

## Clothing Logic

| Feels Like | Clothing |
|------------|----------|
| < 20°F     | 🧥 🧤 🧣 |
| 20-40°F    | 🧥 🧣 |
| 40-60°F    | 🧥 |
| 60-75°F    | 👕 |
| > 75°F     | 👕 🩳 😎 |

## Setup

```bash
brew install imagemagick # macOS (MiniMagick depends on it)
bundle install
cp .env.example .env     # then edit with your location
```

## Running

Continuous mode (updates every second, fetches weather every 60s):

```bash
scripts/weather
```

Preview mode (renders to PNG for testing without device):

```bash
scripts/weather --preview
open /tmp/pixoo_weather_preview.png  # macOS
```

## Configuration

Set these environment variables in `.env`:

**Required:**
- `LOCATION` - City name or address (e.g., `Brooklyn, NY` or `123 Main St, Seattle, WA`). Uses OpenStreetMap to find coordinates. If ambiguous or not found, the app exits with suggestions.

**Optional (enables countdown bar):**
- `COUNTDOWN_START` - When countdown starts (e.g., `8:00am`)
- `COUNTDOWN_END` - When countdown ends (e.g., `8:20am`)

## Notes

- `scripts/weather` uses `Pixoo::Client.find_all` to discover your device; your Pixoo should be on the same network.
- Emoji images are downloaded from the Twemoji CDN on first use and cached in `/tmp`.

## Dependencies

- Ruby 3.4.4
- [pixoo](https://github.com/tenderlove/pixoo-rb) gem for device communication
- [Open-Meteo API](https://open-meteo.com/) for weather (no API key needed)
- [Nominatim/OpenStreetMap](https://nominatim.org/) for geocoding (no API key needed)
- ImageMagick for emoji resizing
- dotenv-rails for loading `.env` config
