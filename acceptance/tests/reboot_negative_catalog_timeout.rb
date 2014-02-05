test_name "Windows Reboot Module - Negative - Reboot Catalog Timeout"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
} ~>
reboot { 'now':
  apply => finished,
  catalog_apply_timeout => 1,
} ->
exec { 'c:\\windows\\system32\\ping.exe /n 4 127.0.0.1':
}
MANIFEST

confine :to, :platform => 'windows'

agents.each do |agent|
  step "Attempt Reboot with a Short Catalog Timeout"

  #Apply the manifest.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do |result|
    assert_match /Timed out waiting for process to exit; reboot aborted/,
      result.stderr, 'Expected timeout message is missing'
  end

  #Verify that a shutdown has NOT been initiated.
  ensure_shutdown_not_scheduled(agent)
end
