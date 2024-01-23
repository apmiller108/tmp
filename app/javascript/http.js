export const generateText = ({ input, text_id }) => {
  const body = JSON.stringify({
    generative_text: {
      input, text_id
    }
  });
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
  }

  return fetch('/generative_texts', {
    method: 'POST',
    body,
    headers
  })
}
