class GenerativeImage
  module Stability
    # See https://platform.stability.ai/docs/api-reference

    class Client
      def engines
        response = conn.get(ENGINES_ENDPOINT) do |req|
          req.headers['Accept'] = 'application/json'
        end
        JSON.parse(response.body)
      end

      def text_to_image(prompt:, **opts)
        engine = ENGINES[:xl_v1]
        params = {
          height: opts.fetch(:height, engine[:dimensions].first.split('x')[0].to_i),
          width: opts.fetch(:width, engine[:dimensions].first.split('x')[1].to_i),
          text_prompts: [
            { text: prompt, weight: 0.5 }
          ],
          cfg_scale: 10, # 0..35
          samples: 1, # Number of images to generate
          seed: 0, # Random seed
          steps: 30, # 10..50
          style_preset: opts.fetch(:style, STYLE_PRESETS[:pixel_art])
        }

        response = conn.post(format(GENERATION_ENDPOINT, engine: engine[:id])) do |req|
          req.body = params.to_json
          req.headers['Accept'] = 'image/png'
        end
        response
      end

      private

      def conn
        Faraday.new(
          url: HOST,
          headers: {
            'Authorization': "Bearer #{Rails.application.credentials.fetch(:stability_key)}",
            'Content-Type': 'application/json'
          }
        ) do |f|
          # f.response :raise_error
        end
      end
    end
  end
end
