require 'premailer'
require 'hpricot' # so that premailer uses it
require 'base64'
require 'rack'

def encode_image(path)
  path = "lib/travis/mailer/views/#{path}"
  type = Rack::Mime.mime_type(File.extname(path))
  data = Base64.encode64(File.read(path))
  "data:#{type};base64,#{data}"
end

def inline_images(file)
  html = File.read(file)
  html.gsub!(/<img[^>]+src="([^"]+)"/) do |tag|
    tag.gsub($1, encode_image($1)) rescue tag
  end
  File.open(file, 'w') { |f| f.write(html) }
end

def premailer(source, target)
  css = "#{source.split('.').first}.css"
  File.open(target, 'w+') do |f|
   f.write Premailer.new(source, :preserve_styles => true, :css => css).to_inline_css
  end
end

Dir['lib/travis/mailer/views/**/*.src'].each do |source|
  target = source.gsub('.src', '')
  premailer(source, target)
  inline_images(target)
end
