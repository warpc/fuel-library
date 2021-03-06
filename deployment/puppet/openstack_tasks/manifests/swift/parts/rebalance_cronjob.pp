class openstack_tasks::swift::parts::rebalance_cronjob(
  $master_swift_replication_ip,
  $primary_proxy         = false,
  $rings                 = ['account', 'object', 'container'],
  $ring_rebalance_period = 23,
) {

  # setup a cronjob to rebalance rings periodically on primary
  file { '/usr/local/bin/swift-rings-rebalance.sh':
    ensure  => $primary_proxy ? {
      true    => file,
      default => absent,
    },
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('openstack/swift/swift-rings-rebalance.sh.erb'),
  }

  cron { 'swift-rings-rebalance':
    ensure      => $primary_proxy ? {
      true    => present,
      default => absent,
    },
    command     => '/usr/local/bin/swift-rings-rebalance.sh &>/dev/null',
    environment => [ 'MAILTO=""', 'PATH=/bin:/usr/bin:/usr/sbin' ],
    user        => 'swift',
    hour        => "*/$ring_rebalance_period",
    minute      => '15',
  }

  # setup a cronjob to download rings periodically on secondaries
  file { '/usr/local/bin/swift-rings-sync.sh':
    ensure  => $primary_proxy ? {
      true    => absent,
      default => file,
    },
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('openstack/swift/swift-rings-sync.sh.erb'),
  }

  cron { 'swift-rings-sync':
    ensure      => $primary_proxy ? {
      true    => absent,
      default => present,
    },
    command     => '/usr/local/bin/swift-rings-sync.sh &>/dev/null',
    environment => [ 'MAILTO=""', 'PATH=/bin:/usr/bin:/usr/sbin' ],
    user        => 'swift',
    hour        => "*/$ring_rebalance_period",
    minute      => '25',
  }

}
