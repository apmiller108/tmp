export const generateText = ({ prompt, text_id }) => {
  const body = JSON.stringify({
    generate_text_request: {
      prompt, text_id
    }
  });
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
  }

  return fetch('/generate_text_requests', {
    method: 'POST',
    body,
    headers
  })
}
