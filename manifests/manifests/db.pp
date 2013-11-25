define windowsazure::db (
  $login,
  $password,
  $location
) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    if $login == undef {
      fail("No login specified for provisioning VM.")
    }

    if $password == undef {
      fail("No password specified for provisioning VM.")
    }

    if $location == undef {
      fail("No location specified for provisioning VM.")
    }

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => 'installed',
        provider => 'gem',
      }
    }

    file {"azure_sql_database-${title}.rb":
      path => "/tmp/azure_sql_database-${title}.rb",
      ensure  => file,
      content => template('windowsazure/azure_sql_database.rb.erb'),
      owner   => root,
      group   => root,
      mode    => 644
    }~>

    exec {"SQL database ${title}":
      command => "ruby /tmp/azure_sql_database-${title}.rb",
      require => File["azure_sql_database-${title}.rb"],
      subscribe   => File["azure_sql_database-${title}.rb"],
      refreshonly => true,
      logoutput => true
    }
}