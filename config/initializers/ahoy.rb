class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # disables automatic linking of visits and users
  end
end

# Disable Ahoy for the time being by excluding all requests
Ahoy.exclude_method = ->(controller, request) { true }

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

# Keep it anonymous, we're fine with approximate data
Ahoy.mask_ips = true
Ahoy.cookies = :none
