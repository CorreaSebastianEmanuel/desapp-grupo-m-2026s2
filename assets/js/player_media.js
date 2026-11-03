export const PlayerMedia = {
  mounted() { this.bindImage() },
  updated() { this.bindImage() },
  bindImage() {
    const img = this.el.querySelector('img')
    if (!img) {
      this.unbindImage()
      this.el.classList.remove('media-ready')
      return
    }
    if (this.image && this.image !== img) this.unbindImage()
    if (this.image !== img) {
      this.image = img
      this.onLoad = () => this.el.classList.toggle('media-ready', img.naturalWidth > 0)
      this.onError = () => this.el.classList.remove('media-ready')
      img.addEventListener('load', this.onLoad)
      img.addEventListener('error', this.onError)
    }
    this.el.classList.toggle('media-ready', img.complete && img.naturalWidth > 0)
  },
  unbindImage() {
    this.image?.removeEventListener('load', this.onLoad)
    this.image?.removeEventListener('error', this.onError)
    this.image = null
  },
  destroyed() { this.unbindImage() },
}
