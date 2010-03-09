# This file is part of Sparql.rb.
# 
# Sparql.rb is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Sparql.rb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with Sparql.rb.  If not, see <http://www.gnu.org/licenses/>.


require 'rubygems'
require 'treetop'

support_path = "#{File.dirname(__FILE__)}"


$:.unshift support_path

#raise $:.inspect

Treetop.load "#{File.dirname(__FILE__)}/primitives"
Treetop.load "#{File.dirname(__FILE__)}/prefixed_names"
Treetop.load "#{File.dirname(__FILE__)}/variables"
Treetop.load "#{File.dirname(__FILE__)}/iri"
Treetop.load "#{File.dirname(__FILE__)}/logical_expressions"
Treetop.load "#{File.dirname(__FILE__)}/graph"
Treetop.load "#{File.dirname(__FILE__)}/series"
Treetop.load "#{File.dirname(__FILE__)}/sparql"