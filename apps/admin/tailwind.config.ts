import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: "var(--brand)",
        ink: "var(--ink)",
        paper: "var(--paper)",
        success: "var(--success)",
        warning: "var(--warning)",
        danger: "var(--danger)",
        info: "var(--info)",
      },
      fontFamily: {
        ui: ["var(--font-inter)", "sans-serif"],
        logo: ["var(--font-nunito)", "sans-serif"],
      },
      borderRadius: {
        badge: "4px",
        stepper: "8px",
        button: "14px",
        card: "18px",
        pill: "9999px",
      },
      fontSize: {
        headline: ["17px", { fontWeight: "700" }],
        title: ["14px", { fontWeight: "600" }],
        "body-lg": ["13px", { fontWeight: "400" }],
        caption: ["11px", { fontWeight: "400" }],
        "label-sm": ["9.5px", { fontWeight: "700", letterSpacing: "0.5px" }],
      },
    },
  },
  plugins: [],
};
export default config;
