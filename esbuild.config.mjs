import path from 'path'
import { URL } from 'url'
import esbuild from 'esbuild'
import rails from 'esbuild-rails'
import { aliasPath } from 'esbuild-plugin-alias-path'

// __dirname is not defined in ES modules
const __dirname = new URL('.', import.meta.url).pathname

const options = {
  bundle: true,
  absWorkingDir: path.join(process.cwd(), 'app/javascript'),
  entryPoints: ['application.js'],
  outdir: path.join(process.cwd(), 'app/assets/builds'),
  // Enable if using multiple entry points. See also https://esbuild.github.io/api/#splitting
  splitting: false,
  chunkNames: 'chunks/[name]-[hash]',
  treeShaking: true,
  sourcemap: process.argv.includes('--development'),
  // See also https://esbuild.github.io/api/#minify
  minify: process.argv.includes('--production'),
  // Build command log output: https://esbuild.github.io/api/#log-level
  logLevel: 'info',
  plugins: [
    // Plugin to import JS files by route globbing(eg Stimulus controllers)
    // See also https://github.com/excid3/esbuild-rails
    rails(),
    // See also https://github.com/LinbuduLab/esbuild-plugins/tree/main/packages/esbuild-plugin-alias-path
    aliasPath({
      alias: {
        '@javascript/*': path.resolve(__dirname, './app/javascript'),
        '@wysiwyg/*': path.resolve(__dirname, './app/javascript/wysiwyg')
      }
    })
  ]
}

if (process.argv.includes('--watch')) {
  let ctx = await esbuild.context(options)
  await ctx.watch()
  console.log('watching...')
} else {
  esbuild
    .build(options)
    .catch(() => process.exit(1))
}
