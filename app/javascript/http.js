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

export const createConversation = ({ text_id, memo_id, assistant_response, user_id }) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    conversation: {
      assistant_response, text_id
    }
  })

  const url = memo_id ? `/memos/${memo_id}/conversations` : `/users/${user_id}/conversations`

  return fetch(url, { method: 'POST', headers, body })
}

export const updateConversation = ({ conversation_id, text_id, memo_id, assistant_response }) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    conversation: {
      assistant_response, text_id
    }
  })

  const url = `/memos/${memo_id}/conversations/${conversation_id}`

  return fetch(url, { method: 'PUT', headers, body })
}

export const createUserConversation = ({ text_id, assistant_response, user_id }) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    conversation: {
      assistant_response, text_id
    }
  })

  const url = `/users/${user_id}/conversations`

  return fetch(url, { method: 'POST', headers, body })
}

export const updateUserConversation = ({ conversation_id, text_id, assistant_response, user_id}) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    conversation: {
      assistant_response, text_id
    }
  })

  const url = `/users/${user_id}/conversations/${conversation_id}`

  return fetch(url, { method: 'PUT', headers, body })
}

export const getConversation = async (memo_id) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const response = await fetch(`/memos/${memo_id}/conversations`, {
    method: 'GET',
    headers
  })

  const data = await response.json()
  return data[0]
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
  generateText,
  generateImage,
  createConversation,
  updateConversation,
  autoSaveMemo
}
