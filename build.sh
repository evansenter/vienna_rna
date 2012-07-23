#!/bin/sh
gem uninstall vienna_rna --ignore-dependencies
gem build vienna_rna.gemspec && gem install vienna_rna --no-rdoc --no-ri --ignore-dependencies && ruby -e "require 'vienna_rna'"
