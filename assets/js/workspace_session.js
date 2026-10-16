// Dispose of disconnected sockets before they can replay buffered events.
let recovering = false
function conceal() {
  document.querySelectorAll('[data-private-workspace]').forEach(el => { el.replaceChildren(); el.hidden = true })
  const notice = document.querySelector('#connection-notice')
  if (notice) notice.hidden = false
}
function recover() {
  conceal()
  window.liveSocket?.disconnect()
  if (recovering) return
  recovering = true
  const retry = async () => {
    try {
      await fetch(location.pathname, {cache: 'no-store', credentials: 'same-origin', redirect: 'manual'})
      location.reload()
    } catch (_) { setTimeout(retry, 500) }
  }
  retry()
}
export const WorkspaceSession = {
  disconnected() { recover() },
  reconnected() { if (recovering) recover() }
}
window.addEventListener('pagehide', conceal)
window.addEventListener('pageshow', event => { if (event.persisted) recover() })
window.addEventListener('offline', () => { if (document.querySelector('#workspace')) recover() })
window.addEventListener('online', () => { if (document.querySelector('#workspace')) recover() })
