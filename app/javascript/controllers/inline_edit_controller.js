import { Controller } from '@hotwired/stimulus'

export default class InlineEditController extends Controller {
  static targets = ['field', 'form', 'input']

  onClickField() {
    this.showForm()
    this.inputTarget.focus()
  }

  showForm() {
    this.formTarget.classList.remove('d-none')
    this.fieldTarget.classList.add('d-none')
  }

  hideForm() {
    // On blur if the element is not dirty just hide the form.
    // The change event (eg, element will be dirty) will submit the form, thereby replacing it
    if (this.inputTarget.value === this.inputTarget.defaultValue) {
      this.formTarget.classList.add('d-none')
      this.fieldTarget.classList.remove('d-none')
    }
  }

  // On change event (blur and the value has changed) submits the form via turbo stream request
  save() {
    this.formTarget.requestSubmit()
  }

  // On enter blue the input. If value changed, a change event will be emitted
  // thereby submitting the form; otherwise the form will be hidden without submitting the form
  blurInput() {
    this.inputTarget.blur()
  }

}
