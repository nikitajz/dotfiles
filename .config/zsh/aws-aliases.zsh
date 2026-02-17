# AWS helpers (trimmed from ohmyzsh/aws plugin)
if (( ! ${+commands[aws]} )); then
  return
fi

# Print current profile / region
function agp() { echo $AWS_PROFILE }
function agr() { echo $AWS_REGION }

function aws_profiles() {
  aws --no-cli-pager configure list-profiles 2>/dev/null && return
  [[ -r "${AWS_CONFIG_FILE:-$HOME/.aws/config}" ]] || return 1
  grep --color=never -Eo '\[.*\]' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" \
    | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([^[:space:]]+)\][[:space:]]*$/\2/g'
}

# Set AWS profile; optionally login/logout SSO: asp <profile> [login|logout]
function asp() {
  if [[ -z "$1" ]]; then
    unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_PROFILE_REGION
    echo "AWS profile cleared."
    return
  fi

  local -a available_profiles
  available_profiles=($(aws_profiles))
  if [[ -z "${available_profiles[(r)$1]}" ]]; then
    echo "${fg[red]}Profile '$1' not found in '${AWS_CONFIG_FILE:-$HOME/.aws/config}'" >&2
    echo "Available profiles: ${(j:, :)available_profiles:-no profiles found}${reset_color}" >&2
    return 1
  fi

  export AWS_DEFAULT_PROFILE=$1
  export AWS_PROFILE=$1
  export AWS_EB_PROFILE=$1
  export AWS_PROFILE_REGION=$(aws configure get region)

  if [[ "$2" == "login" ]]; then
    [[ -n "$3" ]] && aws sso login --sso-session $3 || aws sso login
  elif [[ "$2" == "logout" ]]; then
    aws sso logout
  fi
}

# Switch profile with MFA / role assumption support
function acp() {
  if [[ -z "$1" ]]; then
    unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    echo "AWS profile cleared."
    return
  fi

  local -a available_profiles
  available_profiles=($(aws_profiles))
  if [[ -z "${available_profiles[(r)$1]}" ]]; then
    echo "${fg[red]}Profile '$1' not found in '${AWS_CONFIG_FILE:-$HOME/.aws/config}'" >&2
    echo "Available profiles: ${(j:, :)available_profiles:-no profiles found}${reset_color}" >&2
    return 1
  fi

  local profile="$1" mfa_token="$2"
  local aws_access_key_id="$(aws configure get aws_access_key_id --profile $profile)"
  local aws_secret_access_key="$(aws configure get aws_secret_access_key --profile $profile)"
  local aws_session_token="$(aws configure get aws_session_token --profile $profile)"
  local mfa_serial="$(aws configure get mfa_serial --profile $profile)"
  local sess_duration="$(aws configure get duration_seconds --profile $profile)"

  local -a mfa_opt
  if [[ -n "$mfa_serial" ]]; then
    if [[ -z "$mfa_token" ]]; then
      echo -n "MFA token for $mfa_serial: "
      read -r mfa_token
    fi
    if [[ -z "$sess_duration" ]]; then
      echo -n "Session duration in seconds (default 3600): "
      read -r sess_duration
    fi
    mfa_opt=(--serial-number "$mfa_serial" --token-code "$mfa_token" --duration-seconds "${sess_duration:-3600}")
  fi

  local role_arn="$(aws configure get role_arn --profile $profile)"
  local sess_name="$(aws configure get role_session_name --profile $profile)"
  local -a aws_command

  if [[ -n "$role_arn" ]]; then
    local source_profile="$(aws configure get source_profile --profile $profile)"
    local external_id="$(aws configure get external_id --profile $profile)"
    [[ -z "$sess_name" ]] && sess_name="${source_profile:-profile}"
    aws_command=(aws sts assume-role --role-arn "$role_arn" "${mfa_opt[@]}")
    [[ -n "$external_id" ]] && aws_command+=(--external-id "$external_id")
    aws_command+=(--profile="${source_profile:-profile}" --role-session-name "$sess_name")
    echo "Assuming role $role_arn using profile ${source_profile:-profile}"
  else
    aws_command=(aws sts get-session-token --profile="$profile" "${mfa_opt[@]}")
    echo "Obtaining session token for profile $profile"
  fi

  aws_command+=(--query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' --output text)

  local -a credentials
  credentials=(${(ps:\t:)"$(${aws_command[@]})"})
  if [[ -n "$credentials" ]]; then
    aws_access_key_id="${credentials[1]}"
    aws_secret_access_key="${credentials[2]}"
    aws_session_token="${credentials[3]}"
  fi

  if [[ -n "${aws_access_key_id}" && -n "$aws_secret_access_key" ]]; then
    export AWS_DEFAULT_PROFILE="$profile" AWS_PROFILE="$profile" AWS_EB_PROFILE="$profile"
    export AWS_ACCESS_KEY_ID="$aws_access_key_id"
    export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
    [[ -n "$aws_session_token" ]] && export AWS_SESSION_TOKEN="$aws_session_token" || unset AWS_SESSION_TOKEN
    echo "Switched to AWS profile: $profile"
  fi
}

function aws_regions() {
  local region="${AWS_DEFAULT_REGION:-${AWS_REGION:-us-east-1}}"
  if [[ -z "$AWS_DEFAULT_PROFILE" && -z "$AWS_PROFILE" ]]; then
    echo "Set an AWS profile first (asp <profile>)."
    return 1
  fi
  aws ec2 describe-regions --region "$region" \
    | grep RegionName | awk -F ':' '{gsub(/"/, "", $2); gsub(/,/, "", $2); gsub(/ /, "", $2); print $2}'
}

# Set AWS region
function asr() {
  if [[ -z "$1" ]]; then
    unset AWS_DEFAULT_REGION AWS_REGION
    echo "AWS region cleared."
    return
  fi
  export AWS_REGION=$1
  export AWS_DEFAULT_REGION=$1
}

# Tab completion
function _aws_profiles() { reply=($(aws_profiles)) }
compctl -K _aws_profiles asp acp

function _aws_regions() { reply=($(aws_regions)) }
compctl -K _aws_regions asr

# AWS CLI v2 completion
if command -v aws_completer &>/dev/null; then
  autoload -Uz bashcompinit && bashcompinit
  complete -C aws_completer aws
fi
