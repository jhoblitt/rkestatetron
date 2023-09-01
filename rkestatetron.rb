#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

def slurp_cert(path)
  fname = File.basename(path)
  fpath = File.join(File.dirname(__FILE__), 'ssl/etc/kubernetes/ssl', fname)
  if File.exist?(fpath)
    return File.read(fpath)
  else
    raise "File #{fpath} does not exist"
  end
end

tplate_file = File.join(File.dirname(__FILE__), 'cluster.rkestate')

tplate = JSON.load(File.read(tplate_file))
newstate = tplate

# iterate over the desired state of hosts and update the x509 cert/keys
tplate['desiredState']['certificatesBundle'].each do |k, v|
  next if k == 'kube-admin'
  puts k

  puts v['path']
  #puts slurp_cert(v['path'])
  #puts v['certificatePEM']
  newstate['desiredState']['certificatesBundle'][k]['certificatePEM'] = slurp_cert(v['path'])

  puts v['keyPath']
  #puts slurp_cert(v['keyPath'])
  #puts v['keyPEM']
  newstate['desiredState']['certificatesBundle'][k]['keyPEM'] = slurp_cert(v['keyPath'])
end

# copy the desired state to the current state
newstate['currentState']['certificatesBundle'] = newstate['desiredState']['certificatesBundle']

File.write('cluster.rkestate.new', JSON.pretty_generate(newstate))
