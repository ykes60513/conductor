#!/bin/sh
#
#  Copyright 2023 Conductor authors
#  <p>
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
#  the License. You may obtain a copy of the License at
#  <p>
#  http://www.apache.org/licenses/LICENSE-2.0
#  <p>
#  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
#  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
#  specific language governing permissions and limitations under the License.
#

# startup.sh - startup script for the server docker image

echo "Starting Conductor server"

# Start the server
cd /app/libs
echo "Property file: $CONFIG_PROP"
echo $CONFIG_PROP
export config_file=

if [ -z "$CONFIG_PROP" ];
  then
    echo "Using default configuration file";
    export config_file=/app/config/config.properties
  else
    echo "Using '$CONFIG_PROP'";
    export config_file=/app/config/$CONFIG_PROP
fi

echo "Using java options config: $JAVA_OPTS"

# ==============================
# OpenTelemetry Java Agent
# ==============================

OTEL_AGENT_PATH=${OTEL_AGENT_PATH:-/otel/opentelemetry-javaagent.jar}
OTEL_ENABLED=${OTEL_ENABLED:-true}

OTEL_JAVA_OPTS=""

if [ "$OTEL_ENABLED" = "true" ] && [ -f "$OTEL_AGENT_PATH" ]; then
  echo "OpenTelemetry Java Agent enabled: $OTEL_AGENT_PATH"

  OTEL_JAVA_OPTS="
    -javaagent:$OTEL_AGENT_PATH
    -Dotel.service.name=${OTEL_SERVICE_NAME:-conductor-server}
    -Dotel.resource.attributes=${OTEL_RESOURCE_ATTRIBUTES:-env=local,service=conductor}
    -Dotel.traces.exporter=${OTEL_TRACES_EXPORTER:-otlp}
    -Dotel.metrics.exporter=${OTEL_METRICS_EXPORTER:-none}
    -Dotel.logs.exporter=${OTEL_LOGS_EXPORTER:-none}
    -Dotel.exporter.otlp.endpoint=${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4317}
    -Dotel.exporter.otlp.protocol=${OTEL_EXPORTER_OTLP_PROTOCOL:-grpc}
    -Dotel.traces.sampler=${OTEL_TRACES_SAMPLER:-parentbased_traceidratio}
    -Dotel.traces.sampler.arg=${OTEL_TRACES_SAMPLER_ARG:-0.01}
    -Dotel.instrumentation.jdbc.enabled=${OTEL_INSTRUMENTATION_JDBC_ENABLED:-true}
  "
else
  echo "OpenTelemetry Java Agent disabled or not found: $OTEL_AGENT_PATH"
fi

java \
  ${JAVA_OPTS} \
  -DCONDUCTOR_CONFIG_FILE=$config_file \
  -jar conductor-server.jar 
