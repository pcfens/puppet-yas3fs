require 'spec_helper'

describe 'yas3fs::mount', type: :define do
  let :pre_condition do
    'include ::yas3fs'
  end

  let :title do
    'test-mount'
  end

  describe 'on all systems' do
    context 'with upstart' do
      let :params do
        {
          s3_url: 's3://test-bucket',
          local_path: '/media/test-mount',
        }
      end

      let :facts do
        {
          service_provider: 'upstart',
          osfamily: 'Debian'
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/init/s3fs-test-mount.conf',
        'notify' => 'Service[s3fs-test-mount]',
        'content' => /exec \/usr\/local\/bin\/yas3fs -f  \"\$S3_URL\" \"\$LOCAL_PATH\"/
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
          osfamily: 'Debian'
        }
      end

      it {
        is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/init/s3fs-test-mount.conf',
        'notify' => 'Service[s3fs-test-mount]',
        'content' => /exec \/opt\/yas3fs\/venv\/bin\/yas3fs -f  \"\$S3_URL\" \"\$LOCAL_PATH\"/
      )
      }

      it {
        is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      )
      }
    end

    context 'with systemd' do
      let :facts do
        {
          service_provider: 'systemd',
          osfamily: 'Debian'
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
        'content' => /ExecStart=\/usr\/bin\/yas3fs -f  s3:\/\/test-bucket \/media\/test-mount/
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
          osfamily: 'Debian'
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
          'content' => /\/opt\/yas3fs\/venv\/yas3fs -f  s3:\/\/test-bucket \/media\/test-mount/
        )
      }

    end

    context 'with sysvinit' do
      let :facts do
        {
          service_provider: 'sysvinit',
          osfamily: 'Debian'
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
          'content' => /PATH=\/usr\/local\/bin:\$PATH/
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
          osfamily: 'Debian'
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
          'content' => /PATH=\/opt\/yas3fs\/venv:\/usr\/local\/bin:\$PATH/
        )
      }
    end
  end
end
