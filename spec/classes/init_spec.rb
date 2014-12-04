require 'spec_helper'

describe 'postfix', :type => :class do
  ['Debian'].each do |osfamily|
    let(:facts) {{
      :osfamily        => osfamily,
      :operatingsystem => 'Debian',
    }}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_anchor('postfix::begin') }
    it { is_expected.to contain_class('postfix::params') }
    it { is_expected.to contain_class('postfix::install') }
    it { is_expected.to contain_class('postfix::config') }
    it { is_expected.to contain_class('postfix::service') }
    it { is_expected.to contain_anchor('postfix::end') }

    context "on #{osfamily}" do
      describe 'postfix::install' do
        context 'defaults' do
          it do
            is_expected.to contain_package('postfix').with({
              'ensure' => 'present',
            })
          end
        end

        context 'when package latest' do
          let(:params) {{
            :package_ensure => 'latest',
          }}

          it do
            is_expected.to contain_package('postfix').with({
              'ensure' => 'latest',
            })
          end
        end

        context 'when package absent' do
          let(:params) {{
            :package_ensure => 'absent',
            :service_ensure => 'stopped',
            :service_enable => false,
          }}

          it do
            is_expected.to contain_package('postfix').with({
              'ensure' => 'absent',
            })
          end
          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'present',
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
          it do
            is_expected.to contain_service('postfix').with({
              'ensure' => 'stopped',
              'enable' => false,
            })
          end
        end

        context 'when package purged' do
          let(:params) {{
            :package_ensure => 'purged',
            :service_ensure => 'stopped',
            :service_enable => false,
          }}

          it do
            is_expected.to contain_package('postfix').with({
              'ensure' => 'purged',
            })
          end
          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'absent',
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
          it do
            is_expected.to contain_service('postfix').with({
              'ensure' => 'stopped',
              'enable' => false,
            })
          end
        end
      end

      describe 'postfix::config' do
        context 'defaults' do
          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'present',
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end

        context 'when source dir' do
          let(:params) {{
            :config_dir_source => 'puppet:///modules/postfix/Debian/etc/postfix',
          }}

          it do
            is_expected.to contain_file('postfix.dir').with({
              'ensure'  => 'directory',
              'force'   => false,
              'purge'   => false,
              'recurse' => true,
              'source'  => 'puppet:///modules/postfix/Debian/etc/postfix',
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end

        context 'when source dir purged' do
          let(:params) {{
            :config_dir_purge  => true,
            :config_dir_source => 'puppet:///modules/postfix/Debian/etc/postfix',
          }}

          it do
            is_expected.to contain_file('postfix.dir').with({
              'ensure'  => 'directory',
              'force'   => true,
              'purge'   => true,
              'recurse' => true,
              'source'  => 'puppet:///modules/postfix/Debian/etc/postfix',
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end

        context 'when source file' do
          let(:params) {{
            :config_file_source => 'puppet:///modules/postfix/Debian/etc/postfix/main.cf',
          }}

          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'present',
              'source'  => 'puppet:///modules/postfix/Debian/etc/postfix/main.cf',
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end

        context 'when content string' do
          let(:params) {{
            :config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
          }}

          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end

        context 'when content template' do
          let(:params) {{
            :config_file_template => 'postfix/Debian/etc/postfix/main.cf.erb',
          }}

          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end

        context 'when content template (custom)' do
          let(:params) {{
            :config_file_template     => 'postfix/Debian/etc/postfix/main.cf.erb',
            :config_file_options_hash => {
              'key' => 'value',
            },
          }}

          it do
            is_expected.to contain_file('postfix.conf').with({
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'notify'  => 'Service[postfix]',
              'require' => 'Package[postfix]',
            })
          end
        end
      end

      describe 'postfix::service' do
        context 'defaults' do
          it do
            is_expected.to contain_service('postfix').with({
              'ensure' => 'running',
              'enable' => true,
            })
          end
        end

        context 'when service stopped' do
          let(:params) {{
            :service_ensure => 'stopped',
          }}

          it do
            is_expected.to contain_service('postfix').with({
              'ensure' => 'stopped',
              'enable' => true,
            })
          end
        end
      end
    end
  end
end
