#!/usr/bin/env ruby

# --------------------------------------------------------------------------
# Copyright 2002-2006 GridWay Team, Distributed Systems Architecture
# Group, Universidad Complutense de Madrid
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# --------------------------------------------------------------------------

require 'dagman'
require 'optparse'
require 'pp'

# Add current directory so PRE/POST scripts can be executed
ENV['PATH']+=":."

# Add to ruby library path gridway libraries
$:<<ENV["GW_LOCATION"]+"/lib/ruby"

###################
# OPTIONS PARSING #
###################

options={}
parser=OptionParser.new do |opts|
	opts.banner="Usage: #{__FILE__} [options] <dagman file>"
	opts.separator ""
	
	opts.on('-d', '--dot', "Generate DOT file. it is written to STDOUT.") do |d|
			options[:dot]=d
	end
end

begin
	parser.parse(ARGV)
rescue OptionParser::InvalidOption => e
	puts "Error, #{e}"
	exit(-1)
end

# Get dagman file name
# TODO: smarter way to get the file name
dagman_file=ARGV[-1]

if !dagman_file or !File.exists?(dagman_file)
	puts "Dagman file \"#{dagman_file}\" does not exist."
	exit(-1)
end


#############################
# FUNCTIONS THAT DO THE JOB #
#############################

def run_dagman(file)
	parsed_dagman=DAGMan::Parse.new(file)
	parsed_dagman.merge_data
	runner=DAGMan::Runner.new(parsed_dagman.jobs)
	
	iteration=1
	while !runner.finished?
		puts "## Iteration: #{iteration}"
		runner.iterate
		iteration+=1
	end
end

def gen_dot(file)
	parsed_dagman=DAGMan::Parse.new(file)
	puts "digraph gwdag {"
	puts "  node [color=lightblue2, style=filled];"
	parsed_dagman.dependencies.each{|child, parents|
		parents.each{|parent|	puts "  #{parent} -> #{child};" }
	}
	puts "}"
end


#####################
# SELECT WHAT TO DO #
#####################

if options[:dot]
	gen_dot(dagman_file)
else
	run_dagman(dagman_file)
end
