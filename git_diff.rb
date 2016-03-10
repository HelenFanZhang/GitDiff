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
MONITORING_DIRECTORY = ARGV[4]

jenkins_generic_info_json_url = JENKINS_URL + 'job/' + JOB_NAME + '/api/json?'
jenkins_generic_info_json = JSON.parse(Unirest.get(jenkins_generic_info_json_url).raw_body)
last_known_good_build_url = jenkins_generic_info_json['lastSuccessfulBuild']['url'] + 'api/json?'
x = JSON.parse(Unirest.get(last_known_good_build_url).raw_body)
last_known_good_sha = JSON.parse(Unirest.get(last_known_good_build_url).raw_body)['actions'][3]['lastBuiltRevision']['SHA1']

current_build_url = JENKINS_URL + 'job/' + JOB_NAME + '/' + BUILD_ID + '/api/json?'

current_sha = JSON.parse(Unirest.get(current_build_url).raw_body)['actions'][3]['lastBuiltRevision']['SHA1']

g = Git.open(MASTER_DIRECTORY, :log => Logger.new(STDOUT))


puts "last_known_good_sha " + last_known_good_sha
puts "current_sha " + current_sha



last_known_good_sha = '88b039d24d177f353c81b79725c1f2ed8ffd8730'
current_sha = '2cc7005f5bf0735010c055218923e427ea22d13c'
git_diffs = g.diff(last_known_good_sha, current_sha)


puts git_diffs

start_string = "--- a/"
end_string = "\n"

for git_diff in git_diffs
  if git_diff.patch.include? MONITORING_DIRECTORY
    exit(1)
  end
end