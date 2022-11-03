# Drone

# git hooks
1. npm install --save-dev @commitlint/config-conventional @commitlint/cli
2. echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js
3. npm install husky -D 
4. npm set-script prepare "husky install"
5. npx husky add .husky/commit-msg "npx --no -- commitlint --edit $1"
