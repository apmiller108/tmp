function getCsrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content
}

export const generateText = ({ prompt, text_id, temperature, generate_text_preset_id, conversation_id }) => {
  const body = JSON.stringify({
    generate_text_request: {
      prompt, text_id, temperature, generate_text_preset_id, conversation_id,
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

export const createConversation = ({ text_id, memo_id, assistant_response }) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    conversation: {
      assistant_response, text_id, memo_id
    }
  })

  return fetch(`/memos/${memo_id}/conversations`, {
    method: 'POST',
    headers,
    body
  })
}

export const updateConversation = ({ conversation_id, text_id, memo_id, assistant_response }) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    text_id,
    conversation: {
      assistant_response, text_id, memo_id
    }
  })

  return fetch(`/memos/${memo_id}/conversations/${conversation_id}`, {
    method: 'PUT',
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
