require 'spec_helper'

describe 'yas3fs::mount', type: :define do
  let :pre_condition do
    'include ::yas3fs'
  end

  let :title do
    'test-mount'
  end
  let(:facts) do
    facts
  end

  describe 'on Redhat systems' do
    context 'with upstart <= Rhel6' do
      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
        }
      end

      let :facts do
        {
          service_provider: 'upstart',
          osfamily: 'Redhat',
          os: {
            family: 'RedHat',
            hardware: 'x86_64',
            name: 'RedHat',
            release: {
              full: '6.10',
              major: '6',
              minor: '10'
            },

          }
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/init/s3fs-test-mount.conf',
        'notify' => 'Service[s3fs-test-mount]',
        'content' => %r{exec /usr/bin/env yas3fs -f  \"\$S3_URL\" \"\$LOCAL_PATH\"},
      )
      }

      it {
        is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      )
      }
    end

    context 'with upstart and venv_path set to /opt/yas3fs/venv' do
      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
          venv_path: '/opt/yas3fs/venv',
        }
      end

      let :facts do
        {
          service_provider: 'upstart',
          osfamily: 'Redhat',
          os: {
            family: 'RedHat',
            hardware: 'x86_64',
            name: 'RedHat',
            release: {
              full: '6.10',
              major: '6',
              minor: '10'
            },

          }
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/init/s3fs-test-mount.conf',
        'notify' => 'Service[s3fs-test-mount]',
        'content' => %r{exec /opt/yas3fs/venv/bin/yas3fs -f  \"\$S3_URL\" \"\$LOCAL_PATH\"},
      )
      }

      it {
        is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      )
      }
    end

    context 'with systemd >= Rhel7' do
      let :facts do
        {
          service_provider: 'systemd',
          osfamily: 'Redhat',
          os: {
            family: 'RedHat',
            hardware: 'x86_64',
            name: 'RedHat',
            release: {
              full: '7.9',
              major: '7',
              minor: '9'
            },

          }
        }
      end

      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
        }
      end

      it {
        is_expected.to contain_exec('yas3fs_reload_systemd-test-mount').with(
        'command'   => 'systemctl daemon-reload',
        'subscribe' => 'File[yas3fs-test-mount]',
        'before'    => 'Service[s3fs-test-mount]',
      )
      }

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/systemd/system/s3fs-test-mount.service',
        'notify' => 'Service[s3fs-test-mount]',
        'content' => %r{ExecStart=/usr/bin/env yas3fs -f  s3://test-bucket /media/test-mount},
      )
      }

      it {
        is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      )
      }
    end

    context 'with systemd and venv_path set to /opt/yas3fs/venv' do
      let :facts do
        {
          service_provider: 'systemd',
          osfamily: 'Redhat',
          os: {
            family: 'RedHat',
            hardware: 'x86_64',
            name: 'RedHat',
            release: {
              full: '7.9',
              major: '7',
              minor: '9'
            },

          }
        }
      end

      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
          venv_path: '/opt/yas3fs/venv',
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
          'content' => %r{/opt/yas3fs/venv/bin/yas3fs -f  s3://test-bucket /media/test-mount},
        )
      }
    end
  end

  describe 'on Ubuntu systems' do
    context 'with systemd >= 16.04' do
      let :facts do
        {
          service_provider: 'systemd',
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            hardware: 'x86_64',
            name: 'Ubuntu',
            release: {
              major: '20',
            },

          }
        }
      end

      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
        }
      end

      it {
        is_expected.to contain_exec('yas3fs_reload_systemd-test-mount').with(
        'command'   => 'systemctl daemon-reload',
        'subscribe' => 'File[yas3fs-test-mount]',
        'before'    => 'Service[s3fs-test-mount]',
      )
      }

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/systemd/system/s3fs-test-mount.service',
        'notify' => 'Service[s3fs-test-mount]',
        'content' => %r{ExecStart=/usr/bin/env yas3fs -f  s3://test-bucket /media/test-mount},
      )
      }

      it {
        is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      )
      }
    end

    context 'with systemd and venv_path set to /opt/yas3fs/venv' do
      let :facts do
        {
          service_provider: 'systemd',
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            hardware: 'x86_64',
            name: 'Ubuntu',
            release: {
              major: '20',
            },

          }
        }
      end

      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
          venv_path: '/opt/yas3fs/venv',
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
          'content' => %r{/opt/yas3fs/venv/bin/yas3fs -f  s3://test-bucket /media/test-mount},
        )
      }
    end
  end

  describe 'on Esoteric Debian sysvinit system' do
    context 'with sysvinit' do
      let :facts do
        {
          service_provider: 'sysvinit',
          osfamily: 'Debian',
          os: { family: 'Debian' }
        }
      end

      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
          'ensure' => 'present',
          'path'   => '/etc/init.d/s3fs-test-mount',
          'notify' => 'Service[s3fs-test-mount]',
          'content' => %r{PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:\$PATH},
        )
      }

      it {
        is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      )
      }
    end
    context 'with sysvinit and venv_path set to /opt/yas3fs/venv' do
      let :facts do
        {
          service_provider: 'sysvinit',
          osfamily: 'Debian',
          os: { family: 'Debian' }
        }
      end

      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
          venv_path: '/opt/yas3fs/venv',
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
          'content' => %r{PATH=/opt/yas3fs/venv/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:\$PATH},
        )
      }
    end
  end
end
