def attach_remote_image(book, url)
  response = HTTParty.get(url)

  book.update(cover_last_scraped_at: DateTime.now)

  if response.code == 200
    file = Tempfile.new(["downloaded", File.extname(url)])
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

    book.cover_image.analyze

    puts "Image successfully attached for \"#{book.title}\""

    file.close
  else
    puts "Failed to fetch image: #{response.code}"
  end
end
