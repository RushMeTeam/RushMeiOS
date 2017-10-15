#!/bin/bash

# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPT_DIR=$(dirname "$BASH_SOURCE")
cd "$SCRIPT_DIR"

./columnExtensions.sh
./simpleOperators.sh
./specialOperators.sh
./subqueries.sh
./filterAndHavingExtensions.sh

./testSimpleOperators.sh
./testAggregate.sh
./testSpecialOperators.sh
./testSubqueries.sh
