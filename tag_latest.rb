require 'rubygems'
require 'git'

BRANCH = "master"
MASTER_DIRECTORY = ARGV[0]
@monitoring_tag = ARGV[1]
@approved_hash = ARGV[2]
GIT_REPO = ARGV[3]

def monitoring_tag_exist?
  for tag in @g.tags
    if tag.name.include? @monitoring_tag
      return true
    end
  end
  return false
end

@g = Git.open(MASTER_DIRECTORY)
puts "yes before" if monitoring_tag_exist?
@g.delete_tag(@monitoring_tag) if monitoring_tag_exist?
puts "yes after" if monitoring_tag_exist?
@g.add_tag(@monitoring_tag, @approved_hash)
@g.push("origin", "master", opts={:tags => true, :f => true})

