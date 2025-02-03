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


  // createConversation/updateConversation params
  // # {
  // #   contersation: {
  // #     title: '',
  // #     memo_id: '',
  // #     turns_attributes: {
  // #       '0': {
  // #         turnable_type: 'GenerateTextRequest',
  // #         turnable_attributes: {
  // #           prompt:,
  // #           text_id:,
  // #           temperature:,
  // #           generate_text_preset_id:,
  // #         }
  // #       }
  // #     }
  // #   }
  // # }


export const updateConversation = ({ conversation_id, memo_id, user_id  }) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const body = JSON.stringify({
    conversation: {
      memo_id
    }
  })

  const url = `/users/${user_id}/conversations/${conversation_id}`

  return fetch(url, { method: 'PUT', headers, body })
}

export const getConversations = async (user_id, searchParams) => {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'X-CSRF-Token': getCsrfToken()
  }
  const q = Object.entries(searchParams).map(([k, v]) => {
    `q[${k}]=${encodeURIComponent(v)}`
  }).join('&')

  const response = await fetch(`/users/${user_id}/conversations?${q}`, {
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
  generateText,
  generateImage,
  updateConversation,
  autoSaveMemo
}
