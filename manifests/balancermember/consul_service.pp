# == Define Resource Type: haproxy::balancermember::consul_service
#
# This type will setup a balancer member inside a listening service
#  configuration block in /etc/haproxy/haproxy.cfg on the load balancer.
#  currently it only has the ability to specify the instance name,
#  ip address, port, and whether or not it is a backup. More features
#  can be added as needed. The best way to implement this is to export
#  this resource for all haproxy balancer member servers, and then collect
#  them on the main haproxy load balancer.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/concat module on the Puppet Forge and
#  uses storeconfigs on the Puppet Master to export/collect resources
#  from all balancer members.
#
# === Parameters
#
# [*name*]
#   The title of the resource sets the consul service name if not defined.
#
# [*consul_service*]
#   By default, this is the namevar. If you'd like to set a different
#   service name, do so here.
#
# [*listening_service*]
#   The haproxy service's instance name (or, the title of the
#    haproxy::listen resource). This must match up with a declared
#    haproxy::listen resource.
#
# [*consul_datacenter*]
#   An optional string matching the name of the consul datacenter.
#
# [*consul_tag*]
#   A consul tag to use when looking up the nodes for a service.
#
# [*ensure*]
#   If the balancermember should be present or absent.
#    Defaults to present.
#
# [*options*]
#   An array of options to be specified after the server declaration
#    in the listening service's configuration block.
#
# [*define_cookies*]
#   If true, then add "cookie SERVERID" stickiness options.
#    Default false.
#
# === Examples
#
#
define haproxy::balancermember::consul_service (
  $listening_service,
  $consul_service    = $name,
  $consul_datacenter = undef,
  $consul_tag        = undef,
  $ensure            = 'present',
  $options           = '',
  $define_cookies    = false
) {

  if $consul_tag != undef { validate_string($consul_tag) }
  if $consul_datacenter != undef { validate_string($consul_datacenter) }

  concat::fragment { "${listening_service}_balancermember_${name}":
    ensure  => $ensure,
    order   => "20-${listening_service}-01-${name}",
    target  => $::haproxy::config_file,
    content => template('haproxy/haproxy_balancermember_consul_service.erb'),
  }
}
