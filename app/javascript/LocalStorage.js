export default class LocalStorage {
  setConvoShowOptions(value) {
    this.set('conversations.showOptions', value.toString());
  }

  getConvoShowOptions() {
    return this.get('conversations.showOptions');
  }

  set(key, value) {
    if (this.isLocalStorageAvailabel()) {
      localStorage.setItem(key, value);
    }
  }
  get(key) {
    if (this.isLocalStorageAvailabel()) {
      return localStorage.getItem(key);
    }
  }

  isLocalStorageAvailabel() {
    try {
      const test = '__test__';
      localStorage.setItem(test, test);
      localStorage.removeItem(test);
      return true;
    } catch (e) {
      console.error('localStorage is not available:', e)
      return false;
    }
  };

}
