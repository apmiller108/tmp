function getCsrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content
}

function jsonFormatHeaders() {
  return {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
}

export const createConversation = (params) => {
  const { prompt, text_id, temperature, generate_text_preset_id } = params
  const headers = jsonFormatHeaders()
  const body = JSON.stringify({
    conversation: {
      turnable_type: 'GenerateTextRequest',
      prompt,
      text_id,
      temperature,
      generate_text_preset_id
    }
  })

  const url = `/conversations`

  return fetch(url, { method: 'POST', headers, body })
}

export const updateConversation = (params) => {
  const {
    conversation_id, memo_id, prompt, text_id, temperature,
    generate_text_preset_id, image_quality, tool_types
  } = params

  console.log(params)

  const headers = jsonFormatHeaders()
  let body = { conversation: {} }

  if (memo_id) {
    body.conversation.memo_id = memo_id
  }

  if (image_quality) {
    body.conversation.image_quality = image_quality
  }

  if (tool_types !== undefined) {
    body.conversation.tool_types = tool_types
  }

  if (prompt) {
    body.conversation = {
      ...body.conversation,
      prompt,
      text_id,
      temperature,
      generate_text_preset_id,
      turnable_type: 'GenerateTextRequest'
    }
  }
  const url = `/conversations/${conversation_id}`

  return fetch(url, { method: 'PUT', headers, body: JSON.stringify(body) })
}

export const getConversations = async (user_id, searchParams) => {
  const headers = jsonFormatHeaders()
  const q = Object.entries(searchParams).map(([k, v]) => {
    return `q[${k}]=${encodeURIComponent(v)}`
  }).join('&')

  const response = await fetch(`/conversations?${q}`, {
    method: 'GET',
    headers
  })

  const data = await response.json()
  return data
}

export const autoSaveMemo = (memo) => {
  const { title, content, color } = memo
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': getCsrfToken()
  }

  const body = JSON.stringify({
    memo: {
      title, content, color
    }
  })

  if(memo.id) {
    return fetch(`/memos/autosaves/${memo.id}`, {
      method: 'PUT',
      headers,
      body
    })
  } else {
    return fetch('/memos/autosaves', {
      method: 'POST',
      headers,
      body
    })
  }
}

export const generateImage = ({ prompt, negative_prompt, image_name, style, aspect_ratio }) => {
  const body = JSON.stringify({
    generate_image_request: {
      prompt, negative_prompt, image_name, style, aspect_ratio
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
  getConversations,
  generateImage,
  updateConversation,
  createConversation,
  autoSaveMemo
}
