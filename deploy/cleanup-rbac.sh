#!/bin/bash 
# Copyright 2019 Crunchy Data Solutions, Inc.
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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$PGO_CMD --namespace=$PGO_OPERATOR_NAMESPACE get serviceaccount postgres-operator  > /dev/null
if [ $? -eq 0 ]
then
	$PGO_CMD --namespace=$PGO_OPERATOR_NAMESPACE delete serviceaccount postgres-operator
fi

$PGO_CMD get clusterrole pgo-cluster-role   > /dev/null
if [ $? -eq 0 ]
then
	$PGO_CMD delete clusterrole pgo-cluster-role 
fi

$PGO_CMD get clusterrolebinding pgo-cluster-role   > /dev/null
if [ $? -eq 0 ]
then
	$PGO_CMD delete clusterrolebinding pgo-cluster-role  > /dev/null
fi

sleep 5

