#!/usr/bin/env bats

setup() {
  apache2-foreground &
}

teardown() {
  # Unfortunately, killing Apache properly (i.e. send TERM to the master
  # process) runs into https://github.com/sstephenson/bats/issues/80
  # Oh, well...
  killall -KILL apache2
}

@test "PHP is loaded in Apache, and Apache listens on port 80" {
  for i in $(seq 1 10); do
    out="$(curl -sf http://localhost/ || true)"
    if [[ -n "$out" ]]; then
      break
    fi
    sleep 1
  done

  # Ensure that file was loaded
  [[ "$out" =~ 'PHP is running' ]]
  # Ensure that _ENV includes ENV vars
  [[ "$out" =~ "PHP was installed in $PHP_DIR" ]]
  # Ensure that the file wasn't interpreted as HTML
  [[ ! "$out" =~ 'you should not see this' ]]
}
