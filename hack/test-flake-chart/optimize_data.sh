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

# Take input CSV. For each field, if it is the same as the previous row, replace it with an empty string.
awk -F, 'BEGIN {OFS = FS} { for(i=1; i<=NF; i++) { if($i == j[i]) { $i = ""; } else { j[i] = $i; } } printf "%s\n",$0 }'
