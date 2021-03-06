#!/bin/bash

# Copyright 2019 - 2020 Crunchy Data Solutions, Inc.
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

if [ -z $PGO_OPERATOR_NAMESPACE ];
then
	echo "error: \$PGO_OPERATOR_NAME must be set"
	exit 1
fi

if [ -z $PGO_INSTALLATION_NAME ];
then
	echo "error: \$PGO_INSTALLATION_NAME must be set"
	exit 1
fi

echo "creating "$PGO_OPERATOR_NAMESPACE" namespace to deploy the Operator into..."
$PGO_CMD get namespace $PGO_OPERATOR_NAMESPACE > /dev/null 2> /dev/null
if [ $? -eq 0 ]
then
	echo namespace $PGO_OPERATOR_NAMESPACE is already created
else
	$PGO_CMD create namespace $PGO_OPERATOR_NAMESPACE > /dev/null
	echo namespace $PGO_OPERATOR_NAMESPACE created
fi

echo ""
echo "creating namespaces for the Operator to watch and create PG clusters into..."

IFS=', ' read -r -a array <<< "$NAMESPACE"

if [ ${#array[@]} -eq 0 ]
then
    echo "NAMESPACE is empty, updating Operator namespace ${PGO_OPERATOR_NAMESPACE}"
    array=("${PGO_OPERATOR_NAMESPACE}")
fi

if [[ "${PGO_NAMESPACE_MODE:-dynamic}" != "dynamic" ]]
then

	if [[ "${PGO_DYNAMIC_RBAC}" == "true" ]]
	then
		add_ns_script=add-targeted-namespace-dynamic-rbac.sh
	else	
		add_ns_script=add-targeted-namespace.sh
	fi

	for ns in "${array[@]}"
	do
		$PGO_CMD get namespace $ns > /dev/null 2> /dev/null

		if [ $? -eq 0 ]
		then
			echo namespace $ns already exists, updating...
			$PGOROOT/deploy/$add_ns_script $ns > /dev/null
		else
			echo namespace $ns creating...
			$PGOROOT/deploy/$add_ns_script $ns > /dev/null
		fi
	done
fi