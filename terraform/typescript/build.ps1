rd -r "dist"
npm run build
cp package.json dist/
cp package-lock.json dist/
npm install dist --production