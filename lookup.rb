#!/usr/bin/env ruby
#
# Created 27 August 2008 by Daniel Jackoway
# This file will lookup words on http://www.thefreedictionary.com 
#
# Copyright 2008 Daniel Jackoway
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#If you would like to use this software in some manner that violates the terms of the license, please contact me at: 
#danjdel "at(@)" gmail "period(.)" com 
#and ask for my consent. 
#
#
#**USAGE:**
#make a file called in_words.txt with all of the words you want defined, each on its own line
#Example in_words.txt file (note: you don't want the "#"s at the beginning of each line):
#foo
#bar
#word
#etcetera
#run lookup.rb with ruby (you can get ruby from http://www.ruby-lang.org if you don't have it)
#a file definitions.txt will be created with your words and definitions
#
#
#
#__          __     _____  _   _ _____ _   _  _____ 
#\ \        / /\   |  __ \| \ | |_   _| \ | |/ ____|
# \ \  /\  / /  \  | |__) |  \| | | | |  \| | |  __ 
#  \ \/  \/ / /\ \ |  _  /| . ` | | | | . ` | | |_ |
#   \  /\  / ____ \| | \ \| |\  |_| |_| |\  | |__| |
#    \/  \/_/    \_\_|  \_\_| \_|_____|_| \_|\_____|

#
#running the program WILL overwrite any existing file called defintions.txt that is in the same folder as lookup.rb


require 'net/http'
#require 'uri'

def File
  def puts str
    file.write("#{str}\n")
  end
end
word_file = File.new("in_words.txt")
definition_file = File.new("definitions.txt", "w")
word_file.readlines.each{|word|
  word.chomp!
  url = URI.parse("http://www.thefreedictionary.com/#{word}")
  page = Net::HTTP.get(url)
  unless page
    definition_file.puts "#{word}: **no response**"
    next
  end
  
  if index = /<div class="ds-list">/ =~ page
    page = page[index+20..-1]

    index = /<\/b>/ =~ page
    page = page[index+4..-1]
  elsif index = /<div class="ds-single">/ =~ page
    page = page[index+23..-1]
  else
    definition_file.puts"#{word}: **not found**"
    next
  end
  if x = /<div class="sds-list"><b>a\./ =~ page 
    #puts page[0, 100]
    page = page[(/b\./ =~ page)+7..-1] if x<3
    #puts page[0,100]
  end
  indices = [/\./ =~page, /:/ =~page]
  
  index = indices.min
  definition = page[0...index]
  definition = definition[0..-13] if definition[-10..-1]=="especially" 
  definition_file.puts "#{word}: #{definition}"

}
word_file.close
definition_file.close
