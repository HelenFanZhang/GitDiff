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

def get_build_info(build_id)
  current_build_url = JENKINS_URL + 'job/' + JOB_NAME + '/' + build_id.to_s + '/api/json?'
  rest_get(current_build_url)
end

def rest_get(url)
  JSON.parse(Unirest.get(url).raw_body)
end

def get_jenkins_generic_info
  jenkins_generic_info_url = JENKINS_URL + 'job/' + JOB_NAME + '/api/json?'
  rest_get(jenkins_generic_info_url)
end

last_known_good_info_json = get_build_info(get_jenkins_generic_info['lastSuccessfulBuild']['number'])
last_known_good_sha = find_git_commit(last_known_good_info_json)

current_build_info_json = get_build_info(BUILD_ID)
current_sha = find_git_commit(current_build_info_json)

g = Git.open(MASTER_DIRECTORY, :log => Logger.new(STDOUT))

#TODO: raise error when any one of the SHA doesn't exist
raise("current changelist is not suppose to be null") if current_sha.nil?
puts last_known_good_sha
puts current_sha

git_diffs = g.diff(last_known_good_sha, current_sha)


puts git_diffs

for git_diff in git_diffs
  if git_diff.patch.include? MONITORING_DIRECTORY
    exit(1)
  end
end


