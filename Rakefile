desc "Setup gh-pages under docs directory"
task :setup do
  `rm -rf ./docs`
  `mkdir ./docs`
  `cd docs && git clone git@github.com:ciju/unmasker.git . && git checkout origin/gh-pages -b gh-pages && git branch -d master`
end

desc "Deploy docs to github"
task :docco do
  `cp app.js app.css index.html test.html ./docs/`
  `cp -r ./libs ./docs/ `
  `docco app.coffee`
  `cd docs && git add -A && git commit -am 'updating docs' && git push -f origin gh-pages`
end
