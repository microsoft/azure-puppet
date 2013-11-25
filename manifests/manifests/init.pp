
class azure (
  $location     = 'West US',
  $vm_name      = undef,
  $vm_user      = undef,
  $image        = undef,
  $password     = undef
) {
   class { 'windowsazure::vm':
    vm_name      => $vm_name,
    vm_user      => $vm_user,
    image        => $image,
    password     => $password,
    location     => $location
  }
}