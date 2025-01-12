function createGenerativeId(prefix) {
  const timestamp = new Date().getTime()
  const random = Math.floor(Math.random() * 10000)
  return `${prefix}_${timestamp}_${random}`
}

export const createGenTextId = () => {
  return createGenerativeId('gentext')
}

export const createGenImageId = () => {
  return createGenerativeId('genimage')
}

export default {
  createGenTextId,
  createGenImageId
}
