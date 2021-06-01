#!/bin/bash

# Copyright 2018 The Kubernetes Authors All rights reserved.
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

# Create temp path for partial data (storing everything but the commit date.)
PARTIAL_DATA_PATH=$(mktemp)
# Print the partial path for debugging/convenience.
echo "Partial path: $PARTIAL_DATA_PATH" 1>&2

# Print header.
printf "Commit Hash,Commit Date,Environment,Test,Status,Duration\n"

# 1) Turn each test in each summary file to a CSV line containing its commit hash, environment, test, and status.
# 2) Copy partial data to $PARTIAL_DATA_PATH to join with date later.
# 3) Extract only commit hash for each row
# 4) Make the commit hashes unique (we assume that gsutil cats files from the same hash next to each other).
#   Also force buffering to occur per line so remainder of pipe can continue to process.
# 5) Execute git log for each commit to get the date of each.
# 6) Join dates with test data.
jq -r '((.PassedTests[]? as $name | {commit: .Detail.Details, environment: .Detail.Name, test: $name, duration: .Durations[$name], status: "Passed"}),
          (.FailedTests[]? as $name | {commit: .Detail.Details, environment: .Detail.Name, test: $name, duration: .Durations[$name], status: "Failed"}),
          (.SkippedTests[]? as $name | {commit: .Detail.Details, environment: .Detail.Name, test: $name, duration: 0, status: "Skipped"}))
          | .commit + "," + .environment + "," + .test + "," + .status + "," + (.duration | tostring)' \
| tee $PARTIAL_DATA_PATH \
| sed -r -n 's/^([^,]+),.*/\1/p' \
| stdbuf -oL -eL uniq \
| xargs -I {} git log -1 --pretty=format:"{},%as%n" {} \
| join -t "," - $PARTIAL_DATA_PATH
