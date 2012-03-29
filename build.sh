#!/bin/sh
gem uninstall vienna_rna
gem build vienna_rna.gemspec && gem install vienna_rna && ruby -e "require 'vienna_rna'" && irb -r vienna_rna
