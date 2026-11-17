return {
  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        indent = { char = "▏" }, -- left-edge character; avoids Agave rendering │ off-center
        scope  = { char = "▏" },
      },
      picker = {
        sources = {
          files = {
            -- skip media, archives and other binaries you'd never open in an editor
            exclude = {
              "*.mp3", "*.wav", "*.flac", "*.ogg", "*.m4a", "*.aac",
              "*.mp4", "*.mkv", "*.mov", "*.avi", "*.webm",
              "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.ico", "*.bmp",
              "*.pdf", "*.zip", "*.tar", "*.gz", "*.xz", "*.7z", "*.rar",
              "*.iso", "*.deb", "*.AppImage", "*.exe", "*.dll", "*.so", "*.o",
              "*.ttf", "*.otf", "*.woff", "*.woff2",
            },
          },
        },
      },
    },
  },
}
