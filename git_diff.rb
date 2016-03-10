require 'rubygems'
require 'git'
require 'Logger'
require 'json'
require 'unirest'


JENKINS_URL = ARGV[0]
JOB_NAME = ARGV[1]
BUILD_ID = ARGV[2]
MASTER_DIRECTORY = ARGV[3]
#TODO: Need to allow Monitoring_directory to take array of directories
GIT_PATH = ARGV[4]
MONITORING_DIRECTORY = ARGV[5]

def find_git_commit(build_info_json)
  for info in build_info_json['actions']
    next if !info.kind_of?(Hash)
    next if !info.has_key? 'lastBuiltRevision'
    next if !info.has_key? 'remoteUrls'
    if info['remoteUrls'][0].eql? GIT_PATH
      return info['lastBuiltRevision']['SHA1']
    end
  end
  nil
end

jenkins_generic_info_json_url = JENKINS_URL + 'job/' + JOB_NAME + '/api/json?'
jenkins_generic_info_json = JSON.parse(Unirest.get(jenkins_generic_info_json_url).raw_body)
last_known_good_build_url = jenkins_generic_info_json['lastSuccessfulBuild']['url'] + 'api/json?'
last_known_good_info_json = JSON.parse(Unirest.get(last_known_good_build_url).raw_body)
last_known_good_sha = find_git_commit(last_known_good_info_json)

current_build_url = JENKINS_URL + 'job/' + JOB_NAME + '/' + BUILD_ID + '/api/json?'
current_build_info_json = JSON.parse(Unirest.get(current_build_url).raw_body)
current_sha = find_git_commit(current_build_info_json)

g = Git.open(MASTER_DIRECTORY, :log => Logger.new(STDOUT))

#TODO: raise error when any one of the SHA doesn't exist
raise("current changelist is not suppose to be null") if current_sha.nil?
puts last_known_good_sha
puts current_sha

git_diffs = g.diff(last_known_good_sha, current_sha)


puts git_diffs

start_string = "--- a/"
end_string = "\n"

for git_diff in git_diffs
  if git_diff.patch.include? MONITORING_DIRECTORY
    exit(1)
  end
end


