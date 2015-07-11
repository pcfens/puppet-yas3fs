require 'spec_helper'

describe 'yas3fs::mount', :type => :define do

  let :pre_condition do
    'include ::yas3fs'
  end

  let :title do
    'test-mount'
  end
  
  describe 'on all systems' do
    context 'with upstart' do
      let :params do {
        :s3_url     => 's3://test-bucket',
        :local_path => '/media/test-mount',
      } end

      let :facts do {
        :initsystem => 'upstart',
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

    context 'with systemd' do
      let :facts do {
        :initsystem => 'systemd'
      } end

      let :params do {
        :s3_url     => 's3://test-bucket',
        :local_path => '/media/test-mount',
      } end

      it { is_expected.to contain_exec('yas3fs_reload_systemd').with(
        'command'   => 'systemctl daemon-reload',
        'subscribe' => 'File[yas3fs-test-mount]',
        'before'    => 'Service[s3fs-test-mount]',
      ) }

      it { is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/systemd/system/s3fs-test-mount.service',
        'notify' => 'Service[s3fs-test-mount]',
      ) }

      it { is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      ) }
    end

    context 'with sysvinit' do
      let :facts do {
        :initsystem => 'sysvinit'
      } end

      let :params do {
        :s3_url     => 's3://test-bucket',
        :local_path => '/media/test-mount',
      } end

      it { is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/init.d/s3fs-test-mount',
        'notify' => 'Service[s3fs-test-mount]',
      ) }

      it { is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      ) }
    end
  end
end
