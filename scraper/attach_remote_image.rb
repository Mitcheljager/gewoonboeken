require "httparty"
require "tempfile"

def attach_remote_image(book, url)
  response = HTTParty.get(url)

  book.update(cover_last_scraped_at: DateTime.now)

  if response.code != 200
    puts "Failed to fetch image: #{response.code}"
    response = nil
    return
  end

  Tempfile.open(["downloaded", File.extname(url)]) do |file|
    file.binmode
    file.write(response.body)
    file.rewind

    # Get the image width and height, these are later used as an aspect ratio
    # to display the image correctly before it loads. Not all covers are the
    # same aspect ratio, after all.
    image = MiniMagick::Image.read(file)
    width = image.width
    height = image.height

    book.cover_original_width = width
    book.cover_original_height = height
    book.save

    file.rewind

    book.public_send(:cover_image).attach(
      io: file,
      filename: "cover-#{book.isbn}",
      content_type: response.headers["content-type"]
    )

    puts "Image successfully attached for \"#{book.title}\""

    # Reset for garbage collection
    image.destroy! rescue nil
    image = nil
  end

  response = nil
rescue => error
  puts error
end
