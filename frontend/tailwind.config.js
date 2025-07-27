/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'risk-ok': '#10b981', // green
        'risk-watch': '#f59e0b', // yellow
        'risk-alert': '#ef4444', // red
      },
    },
  },
  plugins: [],
}