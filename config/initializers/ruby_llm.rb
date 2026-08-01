RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GEMINI_API_KEY"]
  config.default_model = ENV["GEMINI_DEFAULT_MODEL"]
end
