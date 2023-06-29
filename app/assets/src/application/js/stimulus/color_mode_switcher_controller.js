import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "colorModeButton",
    "lightIcon",
    "darkIcon",
    "autoIcon"
  ]

  static values = {
    lightMode: String,
    darkMode: String,
    autoMode: String
  }

  connect() {
    const colorMode = this.getPreferredColorMode()
    this.setColorMode(colorMode)
  }

  getPreferredColorMode() {
    const storedColorMode = this.getStoredColorMode()

    if (storedColorMode === 'light' || storedColorMode === 'dark' || storedColorMode === 'auto') {
      return storedColorMode
    }

    return 'auto'
  }

  setColorMode(colorMode) {
    if (colorMode === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.documentElement.setAttribute('data-bs-theme', 'dark')
    } else if (colorMode === 'auto' && window.matchMedia('(prefers-color-scheme: light)').matches) {
      document.documentElement.setAttribute('data-bs-theme', 'light')
    } else if (colorMode === 'dark') {
      document.documentElement.setAttribute('data-bs-theme', 'dark')
    } else {
      document.documentElement.setAttribute('data-bs-theme', 'light')
    }

    this.storeColorMode(colorMode)
    this.setUI(colorMode)
  }

  setLightColorMode() {
    this.setColorMode('light')
  }

  setDarkColorMode() {
    this.setColorMode('dark')
  }

  setAutoColorMode() {
    this.setColorMode('auto')
  }

  getStoredColorMode() {
    return localStorage.getItem('color-mode')
  }

  storeColorMode(colorMode) {
    localStorage.setItem('color-mode', colorMode)
  }

  setUI(colorMode) {
    if (colorMode === 'light') {
      this.colorModeButtonTarget.innerHTML = this.lightIconTarget.outerHTML
    } else if (colorMode === 'dark') {
      this.colorModeButtonTarget.innerHTML = this.darkIconTarget.outerHTML
    } else {
      this.colorModeButtonTarget.innerHTML = this.autoIconTarget.outerHTML
    }
  }

}
