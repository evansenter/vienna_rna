#!/bin/sh
gem uninstall vienna_rna
gem build vienna_rna.gemspec && gem install vienna_rna --no-rdoc --no-ri && ruby -e "require 'vienna_rna'"
