# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts 'Creating users...'
users = []
users << User.find_or_create_by!(email: 'rick@example.com') do |user|
  user.password = 'Password!'
  user.password_confirmation = 'Password!'
end
puts "Created users:\n #{users.map(&:email).join("\n")}"

puts 'Inserting LLM Tools'

# GenerateImage
unless LlmTool.where(name: 'GenerateImage').exists?
  ActiveRecord::Base.connection.execute(<<~SQL)
  INSERT INTO llm_tools (name, tool_type, description, input_schema, active, created_at, updated_at)
  VALUES (
  'GenerateImage',
  'image',
  'This tool creates a request to generate an image using a Stable Diffusion generative image AI model. Your job is to turn the user''s request to generate an image into a detailed, thoughtful and effective prompt to produce the best image possible. Use adjectives and detailed descriptive phrases. Be clear about the subject or main focal point of the image. To control the weight of a given word use the format (word:weight), where word is the word you''d like to control the weight of and weight is a value between 0 and 1. For example: The sky was a crisp (blue:0.3) and (green:0.8) would convey a sky that was blue and green, but more green than blue.

  Negative prompt and style are optional, but should be used where needed to produce the most optimal results.

  IMPORTANT: You MUST select the appropriate `request_type`:
  - Use `text_to_image` ONLY when the user is providing text without any reference images.
  - Use `image_to_image` whenever the user has uploaded, attached, or shared an image AND is asking to modify it, use it as a base, or generate something similar. Look for phrases like "based on this image", "edit this picture", "using this image", or when an image is clearly visible in the conversation.
  - Use `upscale` when the user is specifically asking to upscale, enhance, improve quality, or increase resolution of an existing image. Look for phrases like "enhance this image", "upscale this", "make this higher resolution", or "improve the quality of this picture".

  When using `image_to_image`, you should also set an appropriate `strength` value (between 0-1):
  - Lower values (0.1-0.4): Maintain more of the original image''s composition and details
  - Medium values (0.5-0.7): Balance between original image and new elements
  - Higher values (0.8-0.95): More dramatic changes while keeping some influence from original

  CRITICAL: This tool should ONLY be used when the user is EXPLICITLY asking you to create a new image, modify an existing image, or enhance/upscale an image. The user must use clear language indicating they want image generation or modification. Do NOT use this tool for: - General discussions about images - Hypothetical scenarios about what an image or application UI might look like - Analyzing or describing existing images without modification requests - Diagrams, tables, charts - Any request that doesn''t explicitly ask for image creation or modification

  If uncertain whether the user is requesting image generation, ask for clarification before using this tool. It is very important that you use the input schema precisely.',
  '{"type":"object","properties":{"options":{"type":"object","properties":{"request_type":{"type":"string","enum":["text_to_image","image_to_image","upscale"],"description":"The type of image generation request. See tool description."},"style":{"type":"string","enum":["3d-model","analog-film","anime","cinematic","comic-book","digital-art","enhance","fantasy-art","isometric","line-art","low-poly","modeling-compound","neon-punk","origami","photographic","pixel-art","tile-texture"],"description":"Preset used to guide the stylistic output."},"aspect_ratio":{"type":"string","enum":["1:1","5:4","3:2","16:9","21:9","4:5","2:3","9:16","9:21"],"description":"Image dimensions."},"strength":{"type":"number","minimum":0,"maximum":1,"description":"Sometimes referred to as denoising, this parameter controls how much influence the image parameter has on the generated image. A value of 0 would yield an image that is identical to the input. A value of 1 would be as if you passed in no image at all. Only used for image to image requests."}},"required":["aspect_ratio"]},"prompts":{"description":"Prompt and negative prompt to generate an image using Stable Diffusion.","type":"object","properties":{"prompt":{"type":"string","description":"Prompt to generate an image using Stable Diffusion."},"negative_prompt":{"type":"string","description":"Negative prompt to generate an image using Stable Diffusion."}},"required":["prompt"]}},"required":["options","prompts"]}'::json,
  true,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
        )
  SQL
end
