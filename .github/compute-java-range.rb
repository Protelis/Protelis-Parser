#!/usr/bin/env ruby
dockerfile = File.open('.github/Dockerfile').read
latestJava = dockerfile.match(/^FROM\s+eclipse-temurin:(\d+)/)[1]
range = [11] + (17..latestJava.to_i).select { |it| (it - 17) % 4 == 0 } + [latestJava.to_i]
puts("java-range=#{range.uniq}")
