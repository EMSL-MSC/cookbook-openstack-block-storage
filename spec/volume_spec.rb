# encoding: UTF-8
#
# Cookbook Name:: openstack-block-storage

require_relative 'spec_helper'

describe 'openstack-block-storage::volume' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'block-storage-stubs'
    include_examples 'common-logging'

    expect_creates_cinder_conf('service[cinder-volume]', 'cinder', 'cinder')

    it 'installs cinder volume packages' do
      expect(chef_run).to upgrade_package 'cinder-volume'
    end

    it 'starts cinder volume' do
      expect(chef_run).to start_service 'cinder-volume'
    end

    it 'starts cinder volume on boot' do
      expect(chef_run).to enable_service 'cinder-volume'
    end

    it 'starts iscsi target on boot' do
      expect(chef_run).to enable_service 'tgt'
    end

    it 'installs mysql python packages by default' do
      expect(chef_run).to upgrade_package 'python-mysqldb'
    end

    it 'installs postgresql python packages if explicitly told' do
      node.set['openstack']['db']['block-storage']['service_type'] = 'postgresql'

      expect(chef_run).to upgrade_package 'python-psycopg2'
      expect(chef_run).not_to upgrade_package 'python-mysqldb'
    end

    it 'installs cinder iscsi packages' do
      expect(chef_run).to upgrade_package 'tgt'
    end

    it 'installs emc packages' do
      node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.emc.emc_smis_iscsi.EMCSMISISCSIDriver'

      expect(chef_run).to upgrade_package 'python-pywbem'
    end

    context 'IBMNAS Driver' do
      let(:file) { chef_run.template('/etc/cinder/nfs_shares.conf') }
      before do
        node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.ibm.ibmnas.IBMNAS_NFSDriver'
        node.set['openstack']['block-storage']['ibmnas']['nas_access_ip'] = '127.0.0.1'
        node.set['openstack']['block-storage']['ibmnas']['export'] = '/ibm/fs/export'
      end

      it 'creates IBMNAS shares_config file' do
        expect(chef_run).to create_template(file.name).with(
           owner: 'cinder',
           group: 'cinder',
           mode: '0600'
        )
        expect(chef_run).to render_file(file.name).with_content('127.0.0.1:/ibm/fs/export')
      end

      it 'installs nfs packages' do
        expect(chef_run).to upgrade_package 'nfs-common'
      end

      it 'creates the nfs mount point' do
        expect(chef_run).to create_directory('/mnt/cinder-volumes').with(
           owner: 'cinder',
           group: 'cinder',
           mode: '0755'
        )
      end
    end

    context 'NetApp Driver' do
      describe 'NFS' do
        before do
          node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.netapp.nfs.NetAppDirect7modeNfsDriver'
        end

        it 'installs nfs packages' do
          expect(chef_run).to upgrade_package 'nfs-common'
        end

        it 'creates the nfs mount point' do
          expect(chef_run).to create_directory '/mnt/cinder-volumes'
        end
      end

      describe 'ISCSI' do
        before do
          node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.netapp.iscsi.NetAppISCSIDriver'
        end

        it 'configures netapp dfm password' do
          n = chef_run.node['openstack']['block-storage']['netapp']['dfm_password']
          expect(n).to eq 'netapp-pass'
        end
      end
    end

    context 'Ceph (RBD) Driver' do
      let(:file) { chef_run.template('/etc/ceph/ceph.client.cinder.keyring') }
      before do
        node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.rbd.RBDDriver'
        node.set['openstack']['block-storage']['rbd_secret_name'] = 'rbd_secret_uuid'
      end

      it 'fetches the rbd_uuid_secret' do
        n = chef_run.node['openstack']['block-storage']['rbd_secret_uuid']
        expect(n).to eq 'b0ff3bba-e07b-49b1-beed-09a45552b1ad'
      end

      it 'includes the ceph_client recipe' do
        expect(chef_run).to include_recipe('openstack-common::ceph_client')
      end

      it 'installs the needed ceph packages by default' do
        %w{ python-ceph ceph-common }.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'honors package option platform overrides for python-ceph' do
        node.set['openstack']['block-storage']['rbd_secret_name'] = 'rbd_secret_uuid'
        node.set['openstack']['block-storage']['platform']['package_overrides'] = '--override1 --override2'

        %w{ python-ceph ceph-common }.each do |pkg|
          expect(chef_run).to install_package(pkg).with(options: '--override1 --override2')
        end
      end

      it 'honors package name platform overrides for python-ceph' do
        node.set['openstack']['block-storage']['rbd_secret_name'] = 'rbd_secret_uuid'
        node.set['openstack']['block-storage']['platform']['cinder_ceph_packages'] = ['my-ceph', 'my-other-ceph']

        %w{my-ceph my-other-ceph}.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'creates a cephx client keyring correctly' do
        [/^\[client\.cinder\]$/,
         /^  key = cephx-key$/].each do |content|
          expect(chef_run).to render_file(file.name).with_content(content)
        end
        expect(chef_run).to create_template(file.name).with(cookbook: 'openstack-common')
        expect(file.owner).to eq('cinder')
        expect(file.group).to eq('cinder')
        expect(sprintf('%o', file.mode)).to eq '600'
      end
    end

    context 'Storewize Driver' do
      let(:file) { chef_run.template('/etc/cinder/cinder.conf') }
      before do
        node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.storwize_svc.StorwizeSVCDriver'
      end

      it 'configures storewize private key' do
        san_key = chef_run.file chef_run.node['openstack']['block-storage']['san']['san_private_key']
        expect(san_key.mode).to eq('0400')
      end

      context 'ISCSI' do
        before do
          node.set['openstack']['block-storage']['storwize']['storwize_svc_connection_protocol'] = 'iSCSI'
        end

        it 'configures storewize with iscsi' do
          # Test that the FC specific options are not set when connected via iSCSI
          expect(chef_run).not_to render_file(file.name).with_content('storwize_svc_multipath_enabled')
        end
      end

      context 'FC' do
        before do
          node.set['openstack']['block-storage']['storwize']['storwize_svc_connection_protocol'] = 'FC'
        end

        it 'configures storewize with fc' do
          # Test that the iSCSI specific options are not set when connected via FC
          expect(chef_run).not_to render_file(file.name).with_content('storwize_svc_iscsi_chap_enabled')
        end
      end
    end

    describe 'targets.conf' do
      let(:file) { chef_run.template('/etc/tgt/targets.conf') }

      it 'has proper modes' do
        expect(sprintf('%o', file.mode)).to eq '600'
      end

      it 'notifies iscsi restart' do
        expect(file).to notify('service[iscsitarget]').to(:restart)
      end

      it 'has ubuntu include' do
        expect(chef_run).to render_file(file.name).with_content('include /etc/tgt/conf.d/*.conf')
        expect(chef_run).not_to render_file(file.name).with_content('include /var/lib/cinder/volumes/*')
      end
    end

    describe 'create_vg' do
      let(:file) { chef_run.template('/etc/init.d/cinder-group-active') }
      before do
        node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.lvm.LVMISCSIDriver'
        node.set['openstack']['block-storage']['volume']['create_volume_group'] = true
        stub_command('vgs cinder-volumes').and_return(false)
      end

      it 'cinder vg active' do
        expect(chef_run).to enable_service 'cinder-group-active'
      end

      it 'create volume group' do
        volume_size = chef_run.node['openstack']['block-storage']['volume']['volume_group_size']
        seek_count = volume_size.to_i * 1024
        group_name = chef_run.node['openstack']['block-storage']['volume']['volume_group']
        path = chef_run.node['openstack']['block-storage']['volume']['state_path']
        vg_file = "#{path}/#{group_name}.img"
        cmd = "dd if=/dev/zero of=#{vg_file} bs=1M seek=#{seek_count} count=0; vgcreate cinder-volumes $(losetup --show -f #{vg_file})"
        expect(chef_run).to run_execute(cmd)
      end

      it 'notifies cinder group active start' do
        expect(file).to notify('service[cinder-group-active]').to(:start)
      end

      it 'creates cinder group active template file' do
        expect(chef_run).to create_template(file.name)
      end
    end

    describe 'cinder_emc_config.xml' do
      let(:file) { chef_run.template('/etc/cinder/cinder_emc_config.xml') }
      before do
        node.set['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.emc.emc_smis_iscsi.EMCSMISISCSIDriver'
      end

      it 'creates cinder emc config file' do
        expect(chef_run).to create_template(file.name)
      end

      it 'has proper modes' do
        expect(sprintf('%o', file.mode)).to eq('644')
      end

      it 'has StorageType' do
        expect(chef_run).to render_file(file.name).with_content('<StorageType>0</StorageType>')
      end

      it 'has EcomServerIp' do
        expect(chef_run).to render_file(file.name).with_content('<EcomServerIp>127.0.0.1</EcomServerIp>')
      end

      it 'has EcomServerPort' do
        expect(chef_run).to render_file(file.name).with_content('<EcomServerPort>5988</EcomServerPort>')
      end

      it 'has EcomUserName' do
        expect(chef_run).to render_file(file.name).with_content('<EcomUserName>admin</EcomUserName>')
      end

      it 'has EcomPassword' do
        expect(chef_run).to render_file(file.name).with_content('<EcomPassword>emc_test_pass</EcomPassword>')
      end

      it 'does not have MaskingView when not specified' do
        expect(chef_run).not_to render_file(file.name).with_content('<MaskingView>')
      end

      it 'has MaskingView when specified' do
        node.set['openstack']['block-storage']['emc']['MaskingView'] = 'testMaskingView'

        expect(chef_run).to render_file(file.name).with_content('<MaskingView>testMaskingView</MaskingView>')
      end
    end
  end
end
