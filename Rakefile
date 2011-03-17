task :gem do
  sh 'gem build mrT.gemspec'
end

task :install => :gem do
  v = `git describe --abbrev=0`.chomp
  sh "gem install mrT-#{v}.gem"
end

task :default => :install
