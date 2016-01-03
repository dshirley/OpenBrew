#!/bin/bash

API_KEYS_DIR=`dirname ${0}`
CRITTERCISM_OUT=${GENERATED_HEADERS}/CrittercismApiKey.h
GOOGLE_ANALYTICS_OUT=${GENERATED_HEADERS}/GoogleAnalyticsApiKey.h
PASSWORD_FILE=${API_KEYS_DIR}/.password

if [ ! -d ${GENERATED_HEADERS} ]; then
  mkdir -p ${GENERATED_HEADERS}
fi

if [ -f ${CRITTERCISM_OUT} ]; then
  rm ${CRITTERCISM_OUT}
fi

if [ -f ${GOOGLE_ANALYTICS_OUT} ]; then
  rm ${GOOGLE_ANALYTICS_OUT}
fi

if [ -f ${PASSWORD_FILE} ]; then
  openssl aes-256-cbc -k `cat ${PASSWORD_FILE}` -in CrittercismApiKey.h.enc -d -a -out ${CRITTERCISM_OUT}
  openssl aes-256-cbc -k `cat ${PASSWORD_FILE}` -in GoogleAnalyticsApiKey.h.enc -d -a -out ${GOOGLE_ANALYTICS_OUT}
else
  touch ${CRITTERCISM_OUT}
  touch ${GOOGLE_ANALYTICS_OUT}
fi

