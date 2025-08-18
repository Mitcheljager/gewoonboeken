require "httparty"
require_relative "../../config/environment"
require_relative "../get_book"
require_relative "../sources/amazon"
require_relative "../sources/broese"
require_relative "../sources/deslegte"
require_relative "../helpers/log_time"
require_relative "../helpers/log_message"

start_time = DateTime.now

arguments = ARGV.map { |a| a.split("=", 2) }.to_h
base_url = arguments["base_url"]
token = arguments["token"]
sleep_timeout = arguments["sleep"] || 3
source = arguments["source"]
order = arguments["order"] || "hotness"
order_direction = arguments["order_direction"] || "desc"

isbn_list = HTTParty.get(base_url + "/api/books/isbn_list?order=#{ order }&order_direction=#{ order_direction }",
                         headers: { "Token": token })

isbn_list.each_with_index do |isbn, index|
  puts "\e[44m #{index + 1} out of #{isbn_list.size} \e[0m"

  begin
    result = scrape_amazon(isbn)   if source == "Amazon"
    result = scrape_broese(isbn)   if source == "Broese"
    result = scrape_deslegte(isbn) if source == "De Slegte"

    response = HTTParty.post(base_url + "/api/listings/update",
                            headers: { "Token": token },
                            body: { source_name: source, isbn:, listing: { **result } })

    puts "Available: #{result[:available] ? "\e[32m" : "\e[31m"}#{result[:available]}\e[0m"
    puts "Response:  #{response.code == 200 ? "\e[32m" : "\e[31m"}#{response.code}\e[0m"
  rescue => error
    LogMessage.log_error_block(message: "#{source} failed for: #{isbn}", error:)
  end

  sleep(sleep_timeout.to_i)
end

LogTime.log_end_time(start_time)
