import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default [{
    ignores: ["**/builds/*js"],
}, ...compat.extends("eslint:recommended"), {
    languageOptions: {
        globals: {
            ...globals.browser,
            Turbo: "readonly",
            Trix: "readonly",
        },

        ecmaVersion: 2023,
        sourceType: "module",
    },

    rules: {
        "comma-dangle": ["error", "never"],

        "no-param-reassign": ["error", {
            props: false,
        }],

        "no-multi-spaces": "off",
        "function-paren-newline": ["error", "consistent"],
    },
}];
