# ROLE: primary-controller

require 'spec_helper'
require 'shared-examples'
manifest = 'aodh/keystone.pp'

describe manifest do
  test_ubuntu_and_centos manifest
end
