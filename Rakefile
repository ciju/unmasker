desc "Deploy docs to github"
task :docco do
  `docco app.coffee`
  `git add -A`
  `git stash`
  `git checkout gh-pages`
  `rm -rdf docs`
  `git add -A`
  `git stash pop`
  `git commit -am 'updating docs'`
  `git push origin gh-pages`
  `git checkout master`
end
