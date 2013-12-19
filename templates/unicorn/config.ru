# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'unicorn/oob_gc'
require 'unicorn/worker_killer'

use Unicorn::OobGC
use Unicorn::WorkerKiller::MaxRequests, 3072, 4096
use Unicorn::WorkerKiller::Oom, 192.megabytes, 256.megabytes
run Rails.application
