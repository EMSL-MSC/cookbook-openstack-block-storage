# encoding: UTF-8
#
# Cookbook Name:: openstack-block-storage
# Attributes:: default
#
# Copyright 2012, DreamHost
# Copyright 2012, Rackspace US, Inc.
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013, Opscode, Inc.
# Copyright 2013-2014, IBM, Corp
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

########################################################################
# Toggles - These can be overridden at the environment level
default['developer_mode'] = false  # we want secure passwords by default
########################################################################

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['block-storage']['custom_template_banner'] = '
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
'

default['openstack']['block-storage']['verbose'] = 'False'
default['openstack']['block-storage']['debug'] = 'False'

# Specify policy.json remote file to import
default['openstack']['block-storage']['policyfile_url'] = nil

# Default notification_driver and control exchange
default['openstack']['block-storage']['notification_driver'] = 'cinder.openstack.common.notifier.rpc_notifier'
default['openstack']['block-storage']['control_exchange'] = 'cinder'
# Availability zone/region for the OpenStack Block-Storage service
default['openstack']['block-storage']['region'] = node['openstack']['region']
default['openstack']['block-storage']['scheduler_role'] = 'os-block-storage-scheduler'

# Number of workers for OpenStack Volume API service. The
# default is equal to the number of CPUs available. (integer
# value)
default['openstack']['block-storage']['osapi_volume_workers'] = [8, node['cpu']['total'].to_i].min

# Template strings to be used to generate resource names
default['openstack']['block-storage']['volume_name_template'] = 'volume-%s'
default['openstack']['block-storage']['snapshot_name_template'] = 'snapshot-%s'

# The name of the Chef role that knows about the message queue server
# that Cinder uses
default['openstack']['block-storage']['rabbit_server_chef_role'] = 'os-ops-messaging'

# This is the name of the Chef role that will install the Keystone Service API
default['openstack']['block-storage']['keystone_service_chef_role'] = 'keystone'

# Keystone PKI signing directory
default['openstack']['block-storage']['api']['auth']['cache_dir'] = '/var/cache/cinder/api'

default['openstack']['block-storage']['api']['auth']['version'] = node['openstack']['api']['auth']['version']

# A list of memcached server(s) to use for caching
default['openstack']['block-storage']['api']['auth']['memcached_servers'] = nil

# Whether token data should be authenticated or authenticated and encrypted. Acceptable values are MAC or ENCRYPT
default['openstack']['block-storage']['api']['auth']['memcache_security_strategy'] = nil

# This string is used for key derivation
default['openstack']['block-storage']['api']['auth']['memcache_secret_key'] = nil

# Hash algorithms to use for hashing PKI tokens
default['openstack']['block-storage']['api']['auth']['hash_algorithms'] = 'md5'

# A PEM encoded Certificate Authority to use when verifying HTTPs connections
default['openstack']['block-storage']['api']['auth']['cafile'] = nil

# Verify HTTPS connections
default['openstack']['block-storage']['api']['auth']['insecure'] = false

# If True, this indicates that glance-api allows the client to perform
# insecure SSL(https) requests; this should be the same as the setting
# in the glance-api service.
default['openstack']['block-storage']['image']['glance_api_insecure'] = false

# Location of ca certificates file to use for glance client requests
default['openstack']['block-storage']['image']['glance_ca_certificates_file'] = nil

# Which version of the glance API cinder should use when talking to glance.
default['openstack']['block-storage']['image']['glance_api_version'] = 1

# Maximum allocatable gigabytes
# Should equal total backend storage, default is 10TB
default['openstack']['block-storage']['max_gigabytes'] = '10000'

# Storage availability zone
# Default is nova
default['openstack']['block-storage']['storage_availability_zone'] = 'nova'

# Quota definitions
default['openstack']['block-storage']['quota_volumes'] = '10'
default['openstack']['block-storage']['quota_gigabytes'] = '1000'
default['openstack']['block-storage']['quota_driver'] = 'cinder.quota.DbQuotaDriver'
default['openstack']['block-storage']['quota_snapshots'] = 10
default['openstack']['block-storage']['no_snapshot_gb_quota'] = false
default['openstack']['block-storage']['use_default_quota_class'] = true

# Common rpc definitions
default['openstack']['block-storage']['rpc_thread_pool_size'] = 64
default['openstack']['block-storage']['rpc_conn_pool_size'] = 30
default['openstack']['block-storage']['rpc_response_timeout'] = 60
case node['openstack']['mq']['service_type']
when 'rabbitmq'
  default['openstack']['block_storage']['rpc_backend'] = 'cinder.openstack.common.rpc.impl_kombu'
when 'qpid'
  default['openstack']['block_storage']['rpc_backend'] = 'cinder.openstack.common.rpc.impl_qpid'
end

default['openstack']['block-storage']['service_tenant_name'] = 'service'
default['openstack']['block-storage']['service_user'] = 'cinder'
default['openstack']['block-storage']['service_role'] = 'service'

# SAN Support
default['openstack']['block-storage']['san']['san_ip'] = '127.0.0.1'
default['openstack']['block-storage']['san']['san_login'] = 'admin'
default['openstack']['block-storage']['san']['san_private_key'] = '/v7000_rsa'
# The location(URL) of the san_private_key. This value may also specify HTTP(http://), FTP("ftp://"), or local(file://), if the san private key is in the local, you should also specify this attribute using(file://)
default['openstack']['block-storage']['san']['san_private_key_url'] = nil

# NFS support
default['openstack']['block-storage']['nfs']['nas_ip'] = '127.0.0.1'
default['openstack']['block-storage']['nfs']['nas_login'] = 'admin'
default['openstack']['block-storage']['nfs']['nas_ssh_port'] = '22'

# Netapp support
default['openstack']['block-storage']['netapp']['protocol'] = 'http'
default['openstack']['block-storage']['netapp']['dfm_hostname'] = nil
default['openstack']['block-storage']['netapp']['dfm_login'] = nil
default['openstack']['block-storage']['netapp']['dfm_password'] = nil
default['openstack']['block-storage']['netapp']['dfm_port'] = '8088'
default['openstack']['block-storage']['netapp']['dfm_web_port'] = '8080'
default['openstack']['block-storage']['netapp']['storage_service'] = 'storage_service'

# Netapp direct NFS
default['openstack']['block-storage']['netapp']['netapp_server_port'] = '80'
default['openstack']['block-storage']['netapp']['netapp_server_hostname'] = nil
default['openstack']['block-storage']['netapp']['netapp_server_password'] = nil
default['openstack']['block-storage']['netapp']['netapp_server_login'] = nil
default['openstack']['block-storage']['netapp']['export'] = nil
default['openstack']['block-storage']['nfs']['shares_config'] = '/etc/cinder/shares.conf'
default['openstack']['block-storage']['nfs']['mount_point_base'] = '/mnt/cinder-volumes'
default['openstack']['block-storage']['nfs']['nfs_disk_util'] = 'df'
default['openstack']['block-storage']['nfs']['nfs_sparsed_volumes'] = 'true'

# Storwize/SVC Support
default['openstack']['block-storage']['storwize']['san_ip'] = node['openstack']['block-storage']['san']['san_ip']
default['openstack']['block-storage']['storwize']['san_login'] = node['openstack']['block-storage']['san']['san_login']
# If the key is set to nil, the san_login and san_password will be used.
default['openstack']['block-storage']['storwize']['san_private_key'] = node['openstack']['block-storage']['san']['san_private_key']
default['openstack']['block-storage']['storwize']['san_private_key_url'] = node['openstack']['block-storage']['san']['san_private_key_url']
default['openstack']['block-storage']['storwize']['storwize_svc_volpool_name'] = 'volpool'
default['openstack']['block-storage']['storwize']['storwize_svc_vol_rsize'] = 2
default['openstack']['block-storage']['storwize']['storwize_svc_vol_warning'] = 0
default['openstack']['block-storage']['storwize']['storwize_svc_vol_autoexpand'] = true
default['openstack']['block-storage']['storwize']['storwize_svc_vol_grainsize'] = 256
default['openstack']['block-storage']['storwize']['storwize_svc_vol_compression'] = false
default['openstack']['block-storage']['storwize']['storwize_svc_vol_easytier'] = true
default['openstack']['block-storage']['storwize']['storwize_svc_flashcopy_timeout'] = 120
default['openstack']['block-storage']['storwize']['storwize_svc_vol_iogrp'] = 0
default['openstack']['block-storage']['storwize']['storwize_svc_connection_protocol'] = 'iSCSI'
default['openstack']['block-storage']['storwize']['storwize_svc_iscsi_chap_enabled'] = true
default['openstack']['block-storage']['storwize']['storwize_svc_multipath_enabled'] = false
default['openstack']['block-storage']['storwize']['storwize_svc_multihostmap_enabled'] = true
default['openstack']['block-storage']['storwize']['storwize_svc_allow_tenant_qos'] = false
default['openstack']['block-storage']['storwize']['storwize_svc_stretched_cluster_partner'] = nil

# SolidFire Support
default['openstack']['block-storage']['solidfire']['san_ip'] = node['openstack']['block-storage']['san']['san_ip']
default['openstack']['block-storage']['solidfire']['san_login'] = node['openstack']['block-storage']['san']['san_login']
default['openstack']['block-storage']['solidfire']['sf_emulate'] = 'False'
default['openstack']['block-storage']['solidfire']['iscsi_ip_prefix'] = nil

# FlashSystem Support
default['openstack']['block-storage']['flashsystem']['san_ip'] = node['openstack']['block-storage']['san']['san_ip']
default['openstack']['block-storage']['flashsystem']['san_login'] = node['openstack']['block-storage']['san']['san_login']
# The connection protocol for FlashSystem data path (FC only, will introduce iSCSI in Liberty)
default['openstack']['block-storage']['flashsystem']['flashsystem_connection_protocol'] = 'FC'
# The multipath enablement flag (FC only, iSCSI multipath will be controlled by Nova)
default['openstack']['block-storage']['flashsystem']['flashsystem_multipath_enabled'] = false
# Enable vdisk to multi-host mapping
default['openstack']['block-storage']['flashsystem']['flashsystem_multihostmap_enabled'] = true

# EMC VMAX/VNX tSupport
# The EmcUserName user's password is stored in an encrypted databag and
# accessed with openstack-common cookbook library's "get_password" routeine. You
# are expected to create the user and pass in a wrapper cookbook.
default['openstack']['block-storage']['emc']['iscsi_target_prefix'] = 'iqn.1992-04.com.emc'
default['openstack']['block-storage']['emc']['cinder_emc_config_file'] = '/etc/cinder/cinder_emc_config.xml'
default['openstack']['block-storage']['emc']['StorageType'] = 0
default['openstack']['block-storage']['emc']['EcomServerIP'] = '127.0.0.1'
default['openstack']['block-storage']['emc']['EcomServerPort'] = '5988'
default['openstack']['block-storage']['emc']['EcomUserName'] = 'admin'
default['openstack']['block-storage']['emc']['MaskingView'] = nil

# VMware Support
default['openstack']['block-storage']['vmware']['secret_name'] = 'openstack_vmware_secret_name'
default['openstack']['block-storage']['vmware']['vmware_host_ip'] = ''
default['openstack']['block-storage']['vmware']['vmware_host_username'] = ''
default['openstack']['block-storage']['vmware']['vmware_wsdl_location'] = nil
default['openstack']['block-storage']['vmware']['vmware_api_retry_count'] = 10
default['openstack']['block-storage']['vmware']['vmware_task_poll_interval'] = 5
default['openstack']['block-storage']['vmware']['vmware_volume_folder'] = 'cinder-volumes'
default['openstack']['block-storage']['vmware']['vmware_image_transfer_timeout_secs'] = 7200
default['openstack']['block-storage']['vmware']['vmware_max_objects_retrieval'] = 100

# IBM GPFS Support
default['openstack']['block-storage']['gpfs']['gpfs_mount_point_base'] = node['openstack']['block-storage']['gpfs']['gpfs_mount_point_base']
default['openstack']['block-storage']['gpfs']['gpfs_images_dir'] = node['openstack']['block-storage']['gpfs']['gpfs_images_dir']
default['openstack']['block-storage']['gpfs']['gpfs_images_share_mode'] = 'copy_on_write'
default['openstack']['block-storage']['gpfs']['gpfs_sparse_volumes'] = true
default['openstack']['block-storage']['gpfs']['gpfs_max_clone_depth'] = 8
default['openstack']['block-storage']['gpfs']['gpfs_storage_pool'] = 'system'

# IBMNAS (SONAS, Storwize V7000 Unified) Support
# The attribute "nas_password" is stored in databag and
# accessed with openstack-common cookbook library's "get_password" routeine.
default['openstack']['block-storage']['ibmnas']['nas_ip'] = node['openstack']['block-storage']['nfs']['nas_ip']
default['openstack']['block-storage']['ibmnas']['nas_login'] = node['openstack']['block-storage']['nfs']['nas_login']
default['openstack']['block-storage']['ibmnas']['nas_ssh_port'] = node['openstack']['block-storage']['nfs']['nas_ssh_port']
default['openstack']['block-storage']['ibmnas']['shares_config'] = '/etc/cinder/nfs_shares.conf'
default['openstack']['block-storage']['ibmnas']['mount_point_base'] = '/mnt/cinder-volumes'
default['openstack']['block-storage']['ibmnas']['nfs_sparsed_volumes'] = 'true'
default['openstack']['block-storage']['ibmnas']['nas_access_ip'] = nil
default['openstack']['block-storage']['ibmnas']['export'] = nil
# Platform type to be used as backend storage, valid values are:
# 'v7ku : for using IBM Storwize V7000 Unified
# 'sonas : for using IBM Scale Out NAS
# 'gpfs-nas : for using NFS based IBM GPFS deployments
default['openstack']['block-storage']['ibmnas']['ibmnas_platform_type'] = 'v7ku'

# logging attribute
default['openstack']['block-storage']['syslog']['use'] = false
default['openstack']['block-storage']['syslog']['facility'] = 'LOG_LOCAL2'
default['openstack']['block-storage']['syslog']['config_facility'] = 'local2'

default['openstack']['block-storage']['api']['ratelimit'] = 'True'
default['openstack']['block-storage']['cron']['minute'] = '00'
default['openstack']['block-storage']['cron']['audit_logfile'] = '/var/log/cinder/audit.log'

default['openstack']['block-storage']['volume']['state_path'] = '/var/lib/cinder'
default['openstack']['block-storage']['volume']['volumes_dir'] = '/var/lib/cinder/volumes'
default['openstack']['block-storage']['volume']['driver'] = 'cinder.volume.drivers.lvm.LVMVolumeDriver'
default['openstack']['block-storage']['volume']['volume_group'] = 'cinder-volumes'
default['openstack']['block-storage']['volume']['volume_group_size'] = 40
default['openstack']['block-storage']['volume']['volume_clear_size'] = 0
default['openstack']['block-storage']['volume']['volume_clear'] = 'zero'

default['openstack']['block-storage']['volume']['create_volume_group'] = false
# Type of volume group to create:
# - 'file' for basic 40g file for testing
# - 'block_devices' for using block devices, specified in block_devices attribute
default['openstack']['block-storage']['volume']['create_volume_group_type'] = 'file'
# String of local disk device paths
# Examples: '/dev/sdx /dev/sdx1' or '/dev/sd[k-m]1'
default['openstack']['block-storage']['volume']['block_devices'] = nil

default['openstack']['block-storage']['volume']['iscsi_helper'] = 'tgtadm'
default['openstack']['block-storage']['volume']['iscsi_ip_address'] = node['ipaddress']
default['openstack']['block-storage']['volume']['iscsi_port'] = '3260'

# Ceph/RADOS options
default['openstack']['block-storage']['rbd']['cinder']['pool'] = 'volumes'
default['openstack']['block-storage']['rbd']['glance']['pool'] = 'images'
default['openstack']['block-storage']['rbd']['nova']['pool'] = 'instances'
default['openstack']['block-storage']['rbd']['user'] = 'cinder'
default['openstack']['block-storage']['rbd']['secret_uuid'] = '00000000-0000-0000-0000-000000000000'
default['openstack']['block-storage']['rbd']['flatten_volume'] = false
default['openstack']['block-storage']['rbd']['max_clone_depth'] = 5
default['openstack']['block-storage']['rbd']['chunk_size'] = 4
default['openstack']['block-storage']['rbd']['rados_timeout'] = '-1'
default['openstack']['block-storage']['rbd']['conf_dir'] = '/etc/ceph/ceph.conf'

# Multiple backend support
# Allow multiple backends configured in cinder.conf
# For example: {
#                'lvm1' => {
#                  'volume_driver': 'cinder.volume.drivers.lvm.LVMISCSIDriver',
#                  'volume_backend_name': 'lvm-backend-1'
#                }
#                'lvm2' => {
#                  'volume_driver': 'cinder.volume.drivers.lvm.LVMISCSIDriver',
#                  'volume_backend_name': 'lvm-backend-2'
#                }
#              }
default['openstack']['block-storage']['volume']['multi_backend'] = nil

# Default volume-type for volumes to be created as when client does not request
# a specific type.  Volume types are configured from cinder-client and
# will reference the backend name.
default['openstack']['block-storage']['volume']['default_volume_type'] = nil

# Misc option support
# Allow additional strings to be added to cinder.conf
# For example: ['# Comment', 'key=value']
default['openstack']['block-storage']['misc_cinder'] = []

# Default lock_path
# The lock_path normally uses /var/lock/cinder, but it's does not work
# in cases like systemd, so setting lock_path to $state_path/lock like
# in nova and neutron.
default['openstack']['block-storage']['lock_path'] =
  "#{node['openstack']['block-storage']['volume']['state_path']}/lock"

case platform_family
when 'fedora', 'rhel' # :pragma-foodcritic: ~FC024 - won't fix this
  # operating system user and group names
  default['openstack']['block-storage']['user'] = 'cinder'
  default['openstack']['block-storage']['group'] = 'cinder'
  default['openstack']['block-storage']['volume']['iscsi_helper'] = 'lioadm'

  default['openstack']['block-storage']['platform'] = {
    'cinder_common_packages' => ['openstack-cinder'],
    'cinder_api_packages' => ['python-cinderclient'],
    'cinder_api_service' => 'openstack-cinder-api',
    'cinder_client_packages' => ['python-cinderclient'],
    'cinder_volume_packages' => ['qemu-img'],
    'cinder_volume_service' => 'openstack-cinder-volume',
    'cinder_scheduler_packages' => [],
    'cinder_scheduler_service' => 'openstack-cinder-scheduler',
    'cinder_iscsitarget_packages' => ['targetcli'],
    'cinder_iscsitarget_service' => 'target',
    'cinder_ceph_packages' => ['python-ceph', 'ceph-common'],
    'cinder_nfs_packages' => ['nfs-utils', 'nfs-utils-lib'],
    'cinder_emc_packages' => ['pywbem'],
    'cinder_svc_packages' => ['sysfsutils'],
    'cinder_lvm_packages' => ['lvm2'],
    'cinder_flashsystem_packages' => ['sysfsutils'],
    'package_overrides' => ''
  }
when 'suse'
  # operating system user and group names
  default['openstack']['block-storage']['user'] = 'openstack-cinder'
  default['openstack']['block-storage']['group'] = 'openstack-cinder'
  default['openstack']['block-storage']['platform'] = {
    'cinder_common_packages' => ['openstack-cinder'],
    'cinder_api_packages' => ['openstack-cinder-api'],
    'cinder_api_service' => 'openstack-cinder-api',
    'cinder_client_packages' => ['python-cinderclient'],
    'cinder_scheduler_packages' => ['openstack-cinder-scheduler'],
    'cinder_scheduler_service' => 'openstack-cinder-scheduler',
    'cinder_volume_packages' => ['openstack-cinder-volume', 'qemu-img'],
    'cinder_volume_service' => 'openstack-cinder-volume',
    'cinder_ceph_packages' => ['python-ceph', 'ceph-common'],
    'cinder_iscsitarget_packages' => ['tgt'],
    'cinder_iscsitarget_service' => 'tgtd',
    'cinder_nfs_packages' => ['nfs-utils'],
    'cinder_emc_packages' => ['python-pywbem'],
    'cinder_svc_packages' => ['sysfsutils'],
    'cinder_lvm_packages' => ['lvm2'],
    'cinder_flashsystem_packages' => ['sysfsutils']
  }
when 'debian'
  # operating system user and group names
  default['openstack']['block-storage']['user'] = 'cinder'
  default['openstack']['block-storage']['group'] = 'cinder'
  default['openstack']['block-storage']['platform'] = {
    'cinder_common_packages' => ['cinder-common'],
    'cinder_api_packages' => ['cinder-api', 'python-cinderclient'],
    'cinder_api_service' => 'cinder-api',
    'cinder_client_packages' => ['python-cinderclient'],
    'cinder_volume_packages' => ['cinder-volume', 'qemu-utils'],
    'cinder_volume_service' => 'cinder-volume',
    'cinder_scheduler_packages' => ['cinder-scheduler'],
    'cinder_scheduler_service' => 'cinder-scheduler',
    'cinder_ceph_packages' => ['python-ceph', 'ceph-common'],
    'cinder_iscsitarget_packages' => ['tgt'],
    'cinder_iscsitarget_service' => 'tgt',
    'cinder_nfs_packages' => ['nfs-common'],
    'cinder_emc_packages' => ['python-pywbem'],
    'cinder_svc_packages' => ['sysfsutils'],
    'cinder_lvm_packages' => ['lvm2'],
    'cinder_flashsystem_packages' => ['sysfsutils'],
    'package_overrides' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
