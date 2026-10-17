import { Plugin } from "@opencode/plugin/tui"
import { createSignal, onCleanup } from "solid-js"

const label = "Need a JB? "
const url = "https://t.me/jailbreakall"

function rainbow(hue: number) {
  const channel = (offset: number) => {
    const k = (offset + hue / 30) % 12
    return Math.round(255 * (0.65 - 0.35 * Math.max(-1, Math.min(k - 3, 9 - k, 1))))
      .toString(16).padStart(2, "0")
  }
  return `#${channel(0)}${channel(8)}${channel(4)}`
}

// UI only: animation never sends prompts or makes network requests.
export default Plugin.define({
  id: "jb.launcher.banner",
  setup(context) {
    const Banner = () => {
      const [phase, setPhase] = createSignal(0)
      const timer = setInterval(() => setPhase((value) => (value + 8) % 360), 100)
      onCleanup(() => clearInterval(timer))
      const color = (index: number) => rainbow((phase() + index * 14) % 360)
      return (
        <box paddingLeft={1} paddingRight={1} flexDirection="row" flexWrap="wrap">
          {Array.from(label).map((character, index) => (
            <text fg={color(index)}><b>{character}</b></text>
          ))}
          {Array.from(url).map((character, index) => (
            <text fg={color(index + label.length)}>
              <a href={url}><u>{character}</u></a>
            </text>
          ))}
        </box>
      )
    }
    const removeHome = context.ui.slot({ before: "home.footer", render: Banner })
    const removeSession = context.ui.slot({ before: "session.composer.top", render: Banner })
    return () => { removeHome(); removeSession() }
  },
})
