loop do
  script_path = File.expand_path("run_all_scrapers.rb", __dir__)
  system("ruby", script_path, "hours_ago=72")

  sleep(3600)
end
