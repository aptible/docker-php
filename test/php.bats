#!/usr/bin/env bats

@test "PHP can run and is on PATH" {
  php --version
}
