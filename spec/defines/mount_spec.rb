require 'spec_helper'

describe 'yas3fs::mount', :type => :define do

  let :pre_condition do
    'include ::yas3fs'
  end

  let :title do
    'test-mount'
  end

  context 'at a minimum' do
    let :params do {
      :s3_url     => 's3://test-bucket',
      :local_path => '/media/test-mount',
    } end

    it { is_expected.to contain_file('yas3fs-test-mount').with(
      'ensure' => 'present',
      'path'   => '/etc/init/s3fs-test-mount.conf',
      'notify' => 'Service[s3fs-test-mount]',
    ) }

    it { is_expected.to contain_service('s3fs-test-mount').with(
      'ensure' => 'running',
      'enable' => true,
    ) }
  end

  context 'with options' do
    let :params do {
      :s3_url     => 's3://test-bucket',
      :local_path => '/media/test-mount',
      :options    => [
        'recheck-s3',
        'uid 1000',
        'gid 1000',
      ]
    } end

    it { is_expected.to contain_file('yas3fs-test-mount').with(
      'ensure' => 'present',
      'path'   => '/etc/init/s3fs-test-mount.conf',
      'notify' => 'Service[s3fs-test-mount]',
    ) }

    it { is_expected.to contain_service('s3fs-test-mount').with(
      'ensure' => 'running',
      'enable' => true,
    ) }

  end
end
