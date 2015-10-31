#!/bin/bash

INSTANCES=2
HOSTNAME=firehose-to-syslog

echo
echo "The following settings will be used to set the environment variables for the app."
echo "It does not override the manifest.yml, so if you have set env variables in the manifest"
echo "those will override these after the app is pushed. Just hit [ENTER] to skip any question."
echo
read -p "Cloud Foundry API endpoint (e.g. https://api.system.cf.com): " API_ENDPOINT
if [[ $API_ENDPOINT != '' ]]; then
  cf set-env firehose-to-syslog API_ENDPOINT $API_ENDPOINT
fi

read -p "Skip SSL validation? [false]: " SKIP_SSL_VALIDATION
if [[ $SKIP_SSL_VALIDATION == 'true' ]]; then
  cf set-env firehose-to-syslog SKIP_SSL_VALIDATION $SKIP_SSL_VALIDATION
fi

read -p "Cloud Foundry Doppler endpoint (e.g. wss://doppler.system.cf.com:443): " DOPPLER_ENDPOINT
if [[ $DOPPLER_ENDPOINT != '' ]]; then
  cf set-env firehose-to-syslog DOPPLER_ENDPOINT $DOPPLER_ENDPOINT
fi

read -p "Syslog IP address and Port (e.g. 10.9.8.50:514): " SYSLOG_ENDPOINT
if [[ $SYSLOG_ENDPOINT != '' ]]; then
  cf set-env firehose-to-syslog SYSLOG_ENDPOINT $SYSLOG_ENDPOINT
fi

read -p "Comma separated list of events you would like to capture. (e.g. LogMessage,ValueMetric,Error,ContainerMetric) [LogMessage]: " EVENTS
if [[ $EVENTS != '' ]]; then
  cf set-env firehose-to-syslog EVENTS $EVENTS
fi

read -p "Log the counters for all selected events since nozzle was last started. [false]: " LOG_EVENT_TOTALS
if [[ $LOG_EVENT_TOTALS == 'true' ]]; then
  cf set-env firehose-to-syslog LOG_EVENT_TOTALS $LOG_EVENT_TOTALS
  read -p "How frequently the event totals are calculated (in sec) [30s]: " LOG_EVENT_TOTALS_TIME
  if [[ $LOG_EVENT_TOTALS_TIME != '' ]]; then
    cf set-env firehose-to-syslog LOG_EVENT_TOTALS_TIME $LOG_EVENT_TOTALS_TIME
  fi
fi

read -p "Id for the subscription [firehose]: " FIREHOSE_SUBSCRIPTION_ID
if [[ $FIREHOSE_SUBSCRIPTION_ID != '' ]]; then
  cf set-env firehose-to-syslog FIREHOSE_SUBSCRIPTION_ID $FIREHOSE_SUBSCRIPTION_ID
fi

read -p "Username of user with the doppler.firehose permission: " FIREHOSE_USER
if [[ $FIREHOSE_USER != '' ]]; then
  cf set-env firehose-to-syslog FIREHOSE_USER $FIREHOSE_USER
fi

read -p "Password for user with the doppler.firehose permission: " FIREHOSE_PASSWORD
if [[ $FIREHOSE_PASSWORD != '' ]]; then
  cf set-env firehose-to-syslog FIREHOSE_PASSWORD $FIREHOSE_PASSWORD
fi

read -p "Enable debug mode. This disables forwarding to syslog. [false]: " DEBUG
if [[ $DEBUG == 'true' ]]; then
  cf set-env firehose-to-syslog DEBUG $DEBUG
fi

read -p "How many instances of this app do you want to run? [2] " INSTANCES
if [[ $INSTANCES == '' ]]; then
  INSTANCES=2
fi

read -p "Choose to either 1 to push or 2 to restart the app. [1] " choices
if [[ $choices == '' ]]; then
  choices=1
fi
for choice in $choices
do
    case $choice in
        1)
            cf push -i $INSTANCES -n $HOSTNAME --no-route
            ;;
        2)
            echo "This will override any env vars set in the manifest.yml."
            read -p "Are you sure you want to restart? [y/n]" answer
            if [[ $answer == 'y' || $answer == 'yes' ]]; then
              cf restart $HOSTNAME
            fi
            ;;
        *)
            echo "Error select option 1 or 2";;
    esac
done

cf env $HOSTNAME
