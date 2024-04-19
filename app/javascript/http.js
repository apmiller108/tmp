function getCsrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content
}

export const generateText = ({ prompt, text_id, temperature, generate_text_preset_id, conversation_id }) => {
  const body = JSON.stringify({
    generate_text_request: {
      prompt, text_id, temperature, generate_text_preset_id, conversation_id
    }
  })
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': getCsrfToken()
  }

  return fetch('/generate_text_requests', {
    method: 'POST',
    headers,
    body
  })
}

export const generateImage = ({ prompts, image_name, style, dimensions }) => {
  const body = JSON.stringify({
    generate_image_request: {
      prompts, image_name, style, dimensions
    }
  })
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': getCsrfToken()
  }

  return fetch('/generate_image_requests', {
    method: 'POST',
    headers,
    body
  })
}

export default {
  generateText,
  generateImage
}
