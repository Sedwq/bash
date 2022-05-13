#!/bin/bash

###
# Returns GTF orders number where status == ${status} and since > ${since}
# Returns -1 if anything fails
###

# Fail fast
set -eo pipefail


# TODO: Change for a least privilege RO user
user="********"
password="********"


# Debug only : Maps status IDs with status names
declare -a statusMapping=('waiting' 'error' 'done' 'notRunnable' 'running' 'notAuthorized' 'stopped')

# Trap on EXIT (Can't trap on ERR only <- would not trap func and subshell ERR)
trap 'catch $? $LINENO' EXIT #ERR

catch() {
  # Outputs -1 on ERR ; Do nothing otherwise
  if [[ $? -ne 0 ]]; then
    #echo "Error $1 occurred on line $2" >&2
    echo -1
  fi
}

# Get params
status=${1}
env="${2-fme2.citegestion.fr}"
since=${3-$(date +'%Y-%m-%d 00:00:00')}

error(){ 
    echo "ERREUR : parametres invalides !" >&2
	echo "Usage: $0 [1-2-3-4-5-6-7] {env} {date}"  >&2 
    exit 1 
} 

# Fail when missing param or ${status} not in range
[[ -z "$status" || ! $status =~ ^[1-7]$ ]] && error

# Get Auth Token
token=$(
  curl "https://$env/rest/vitis/privatetoken?vitis_version=2969" \
    -sSfm 5 \
    -H "Accept: application/json" \
    --data '{"user":"'$user'","password": "'$password'"}' \
 | jq -r '.token'
)


# GTF returns HTTP 200 on auth err ...
# exit 1 when auth didn't return a token
[[ "$token" == "null" ]] && exit 1

# Get orders by ${status} since ${order_date}
getStatus() {

  status="${1}"
  order_date="${2}"

  [[ -z "$status" || -z "$order_date" ]] && exit 1

  # With order_status_id values :
  # - 1: En attente
  # - 2: En erreur
  # - 3: Traité
  # - 4: Non traitable
  # - 5: En cours
  # - 6: Non autorisé
  # - 7: Stoppé

  # Describe filters outside for readability
  filter=$(
    echo '{
      "relation":"AND",
      "operators":[
        {"column":"order_date","compare_operator":">","value":"'$order_date'"},
        {"column":"order_status_id","compare_operator":"=","value":'$status'}
      ]
    }' \
    | jq -rc .
  )

  response=$(
    curl "https://$env/rest/gtf/authororders" \
      --data-urlencode "vitis_version=2969" \
      --data-urlencode "order_by=order_id" \
      --data-urlencode "sort_order=DESC" \
      --data-urlencode "offset=0" \
      --data-urlencode "limit=1" \
      --data-urlencode "attributs=order_status_id" \
      --data-urlencode "filter=$filter" \
      -GsSfm 5 \
      -H "Accept: application/json"   \
      -H "Token: $token"
  )

  total_row_number=$(
    echo $response \
    | jq '.total_row_number'
  )

  [[ "$total_row_number" == "null" ]] && exit 1 || echo $total_row_number
}

ordersByStatusNbr=$(getStatus $status $since)

# DEBUG
#echo "$ordersByStatusNbr orders with status $status:${statusMapping[(($status - 1))]} since $since"

echo $ordersByStatusNbr

