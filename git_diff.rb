require 'rubygems'
require 'git'
require 'Logger'

MASTER_DIRECTORY = ARGV[0]
#TODO: Need to allow Monitoring_directory to take array of directories
MONITORING_DIRECTORY = ARGV[1]
@monitoring_tag = ARGV[2]

def get_last_known_good_commit_hash
  x = @g.tags
  for tag in @g.tags
    if tag.name.include? @monitoring_tag
      return tag.objectish
    end
  end
  return nil
end

def monitoring_tag_exist?
  for tag in @g.tags
    if tag.name.include? @monitoring_tag
      return true
    end
  end
  return false
end

logger = Logger.new(STDOUT)
@g = Git.open(MASTER_DIRECTORY)
current_sha = @g.log.first.objectish
last_known_good_sha = get_last_known_good_commit_hash

raise("current changelist is not suppose to be null") if current_sha.nil?
raise("last known good commit cannot be null") if last_known_good_sha.nil?
puts last_known_good_sha
puts current_sha

git_diffs = @g.diff(last_known_good_sha, current_sha)

offending_files = []
for git_diff in git_diffs
  if git_diff.patch.include? MONITORING_DIRECTORY
      logger.error(git_diff.patch.split(/\n/).first)
      offending_files << git_diff.patch
  end
end

if !offending_files.empty?
  logger.error("Regions Bank Maybe affected by the differences above")
  exit(1)
else
  @g.delete_tag(@monitoring_tag) if monitoring_tag_exist?

  @g.add_tag(@monitoring_tag)
  @g.describe(current_sha, { @monitoring_tag.to_sym => true})
end




