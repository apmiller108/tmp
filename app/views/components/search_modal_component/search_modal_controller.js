import { Controller } from "@hotwired/stimulus"

export default class SearchModalController extends Controller {
  static targets = ['form', 'input', 'results', 'emptyState', 'loadingState', 'noResultsState']

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      return
    }

    this.emptyStateTarget.classList.add('d-none')
    this.noResultsStateTarget.classList.add('d-none')
    this.resultsTarget.classList.add('d-none')

    this.loadingStateTarget.classList.remove('d-none')

    // This is where you would make an AJAX request to your search endpoint
    // For example:
    // fetch(`/conversations/search?q=${encodeURIComponent(query)}`)
    //   .then(response => response.json())
    //   .then(data => this.displayResults(data))
    //   .catch(error => this.handleError(error))

    // For now, we'll just simulate a response after a delay
    setTimeout(() => {
      this.displaySampleResults(query)
    }, 1000)
  }

  displaySampleResults(query) {
    // This is just sample data for the UI
    const sampleResults = [
      { id: 1, title: "Project discussion with team", snippet: "We need to discuss the new feature implementation...", date: "2023-05-15" },
      { id: 2, title: "Client meeting notes", snippet: "The client requested changes to the dashboard layout...", date: "2023-05-10" },
      { id: 3, title: "Weekly standup", snippet: "Updates on the current sprint progress and blockers...", date: "2023-05-08" }
    ]

    this.loadingStateTarget.classList.add('d-none')
    if (sampleResults.length === 0) {
      this.noResultsStateTarget.classList.remove('d-none')
      return
    }

    const resultsHtml = sampleResults.map(result => `
      <a href="/conversations/${result.id}" class="list-group-item list-group-item-action" data-turbo-frame="conversation_content">
        <div class="d-flex justify-content-between align-items-center">
          <h6 class="mb-1">${result.title}</h6>
          <small class="text-muted">${result.date}</small>
        </div>
        <p class="mb-1">${result.snippet}</p>
      </a>
    `).join('')

    this.resultsTarget.innerHTML = resultsHtml
    this.resultsTarget.classList.remove('d-none')
  }

  handleError(error) {
    console.error("Search error:", error)
    this.resultsTarget.innerHTML = `
      <div class="text-center py-5">
        <i class="bi bi-exclamation-triangle fs-1 text-danger d-block mb-3"></i>
        <p class="text-muted">An error occurred while searching. Please try again.</p>
      </div>
    `
  }
}
