#!/bin/bash

function log {
  echo "> ${*}"
}

log "WORKDIR $(pwd)"

log "Copying bundle cache"
cp -ru "/bundle/.bundle/." "/srv/jekyll/.bundle/"

log "Update bundle"
bundle update

log "Execute Jekyll on :4000"
if [[ -n "${*}" ]];
  then
    log "Using arguments: ${*}"
  fi

bundle exec jekyll serve -H 0.0.0.0 -P 4000
