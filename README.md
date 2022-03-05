# Crystal Open Weather Map Interface

## Deprecated: This shard has been deprecated in favour of my newer [owm.cr](https://github.com/HCLarsen/owm.cr)

A Crystal interface for the Open Weather Map API. Currently, this library supports all the options available to Free Accounts, with the exception of Weather Map Layers.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  open_weather_map:
    github: HCLarsen/open_weather_map
```

## Usage

```crystal
require "open_weather_map"

client = OpenWeatherMap::Client.new(USERS_OWM_KEY)
params = { "q" => "Toronto" }
currentWeather = client.current_weather_for_city(params)

puts "The current weather in Toronto is #{currentWeather.temp}"
```

Note: Users must obtain their own API key from http://openweathermap.org/appid, and substitute their key as USERS_OWM_KEY.

## Development

Tests for the Client class are designed to use a key stored as an environment variable with the name OWM_TEST. Any tests using the Client class will not run without this environment variable.

## Contributing

1. Fork it ( https://github.com/HCLarsen/open_weather_map/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [HCLarsen](https://github.com/HCLarsen) Chris Larsen - creator, maintainer
