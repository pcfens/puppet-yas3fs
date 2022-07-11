# frozen_string_literal: true

require 'spec_helper'

describe 'yas3fs::python' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'class { "yas3fs": }' }

      it { is_expected.to compile }
    end
  end
end
