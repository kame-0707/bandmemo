module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    fontFamily: {
      notosansjp: ["Noto Sans JP"],
    },
  },
  plugins: [require("daisyui")],
  daisyui: { 
    themes: ["nord"],
  },
}