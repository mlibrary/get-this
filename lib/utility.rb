class Sinatra::Request
  def js_filename
    path.tr("/", " ").strip.tr(" ", "-")
  end
end
