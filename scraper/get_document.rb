require "httparty"
require "nokogiri"

def get_document(url, return_url: false, headers: {}, timeout: 5)
  puts "Fetching URL: #{url}"

  user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.5481.100 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15"
  ]

  default_headers = {
    "User-Agent" => user_agents.sample
  }

  begin
    response = HTTParty.get(url, headers: default_headers.merge(headers), timeout: timeout)

    if response.code == 200 || response.code == 202
      body = Nokogiri::HTML(response.body)

      if return_url
        url = response.request.last_uri.to_s
        [url, body]
      else
        body
      end
    else
      puts "Response for #{url} failed with code " + response.code.to_s
    end
  rescue => error
    puts "Response for #{url} resulted in an error"
    puts error
  ensure
    # Set to nil to garbage collect later
    response = nil
    body = nil
  end
end

# Used as a fallback if accessing a URL directly via an inferred path is not possible
def get_search_document(source_url, isbn)
  # Disabled for the time being, too expensive
  return [nil, nil]

  query = "\"#{isbn}\" site:#{source_url}"
  url = "https://api.search.brave.com/res/v1/web/search"

  headers = {
    "Accept" => "application/json",
    "X-Subscription-Token" => ENV["BRAVE_API_KEY"]
  }

  params = {
    country: "nl",
    q: query,
    count: 1
  }

  begin
    response = HTTParty.get(url, query: params, headers:)

    if response.code != 200
      puts "Google API error: #{response.code} - #{response.body}"
      return nil
    end

    results = JSON.parse(response.body)
    first_result = results.dig("web", "results", 0)

    if !first_result
      puts "Brave API returned no results for #{isbn}"
      return nil
    end

    url = first_result["url"]
    title = first_result["title"]

    puts "Found via Brave: #{title} (#{url})"

    url, document = get_document(url, return_url: true)

    [url, document]
  rescue => error
    puts "Response for #{url} resulted in an error"
    puts error
  ensure
    # Set to nil to garbage collect later
    response = nil
    document = nil
  end
end
