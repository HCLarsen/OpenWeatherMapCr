require "http/client"
require "json"

require "./current_weather"
require "./five_day_forecast"

# A client for interfacing with the Open Weather Map API.
class OpenWeatherMap::Client
  @@base_address = "http://api.openweathermap.org/data/2.5/"
  def initialize(key : String)
    @key = key
  end

  # Requests current weather information for a single city by passing in required
  # parameters as a hash.
  # The Hash must have one of the following sets of keys:
  # q : Querying by the city name.
  # id : Querying by the city ID.
  # lat & lon : Querying by latitudinal and longitudinal values.
  # zip : For American addresses, querying by the zip code.
  def current_weather_for_city(params : Hash(String, _) )
    data = get_data(@@base_address + "weather?", params)
    CurrentWeather.from_json(data.body)
  end

  # Requests current weather information for multiple cities by passing in required
  # parameters as a hash.
  # The Hash must have one of the following sets of keys:
  # lat, lon, cnt : Query for cnt number of cities nearest to the lat and lon
  # coordinates provided.
  # bbox : Query for all cities within a rectangle of coordinates provided.
  # id : Query by a list of city IDs.
  def current_weather_for_cities(params : Hash(String, _) )
    case
    when params.keys.includes?("bbox")
      address = @@base_address + "bbox?"
    when params.keys.includes?("lat") && params.keys.includes?("lon") && params.keys.includes?("cnt")
      address = @@base_address + "find?"
    when params.keys.includes?("id")
      address = @@base_address + "group?"
    else
      raise "Invalid Parameters"
    end

    data = get_data(address, params)
    value = JSON.parse(data.body)
    cities = value["list"].as_a
    cities.map do |city|
      CurrentWeather.from_json(city.to_json.to_s)
    end
  end

  # Requests 5 day/3 hour weather forecast for a single city by passing in required
  # parameters as a hash.
  # The Hash must have one of the following sets of keys:
  # q : Querying by the city name.
  # id : Querying by the city ID.
  # lat & lon : Querying by latitudinal and longitudinal values.
  # zip : For American addresses, querying by the zip code.
  def five_day_forecast_for_city(params : Hash(String, _) )
    data = get_data(@@base_address + "forecast?", params)
    FiveDayForecast.from_json(data.body)
  end

  # Requests sunrise and sunset times for a single city by passing in required
  # parameters as a hash.
  # The Hash must have one of the following sets of keys:
  # q : Querying by the city name.
  # id : Querying by the city ID.
  # lat & lon : Querying by latitudinal and longitudinal values.
  # zip : For American addresses, querying by the zip code.
  def sunrise_sunset_for_city(params : Hash(String, _) )
    data = get_data(@@base_address + "weather?", params)
    value = JSON.parse(data.body)
    [Time.new(seconds: value["sys"]["sunrise"].as_i64, nanoseconds: 0, location: Time::Location.local), Time.new(seconds: value["sys"]["sunset"].as_i64, nanoseconds: 0, location: Time::Location.local)]
  end

  private def get_data(address : String, input_params : Hash(String, _) )
    raise "Invalid Parameters" if input_params.empty?
    params = { "APPID" => @key }
    input_params.each do |k,v|
      case v
      when Array
        params[k] = v.to_s.lchop.rchop.split.join
      when String
        params[k] = v
      else
        params[k] = v.to_s
      end
    end

    address += HTTP::Params.encode(params)

    data = HTTP::Client.get address
    if 200 <= data.status_code < 300
      data
    else
      raise "#{data.status_code}:#{data.status_message}"
    end
  end
end
