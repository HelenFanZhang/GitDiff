require 'rubygems'
require 'git'
require 'Logger'

MASTER_DIRECTORY = ARGV[0]
@monitoring_tag = ARGV[1]

def monitoring_tag_exist?
  for tag in @g.tags
    if tag.name.include? @monitoring_tag
      return true
    end
  end
  return false
end


@g = Git.open(MASTER_DIRECTORY)
current_sha = @g.log.first.objectish
@g.delete_tag(@monitoring_tag) if monitoring_tag_exist?
@g.add_tag(@monitoring_tag)
@g.describe(current_sha, { @monitoring_tag.to_sym => true })