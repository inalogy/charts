{{/*
Return the proper MidPoint image name
*/}}
{{- define "midpoint.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper config init image name
*/}}
{{- define "midpoint.configInit.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.configInit.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper jmx image name
*/}}
{{- define "midpoint.metrics.jmx.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.jmx.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Container Image Registry Secret Names
*/}}
{{- define "midpoint.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.configInit.image .Values.metrics.jmx.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "midpoint.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for PostgreSQL
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "midpoint.postgresql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Return the Database Url
*/}}
{{- define "midpoint.database.url" -}}
  {{- printf "jdbc:postgresql://%s:%s/%s" ( include "midpoint.database.host" .) (include "midpoint.database.port" .) ( include "midpoint.database.name" .) -}}
{{- end -}}


{{/*
Return the Database Hostname
*/}}
{{- define "midpoint.database.host" -}}
{{- ternary (include "midpoint.postgresql.fullname" .) .Values.externalDatabase.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "midpoint.database.port" -}}
{{- ternary "5432" .Values.externalDatabase.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the Database Name
*/}}
{{- define "midpoint.database.name" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.global.postgresql }}
        {{- if .Values.global.postgresql.auth }}
            {{- coalesce .Values.global.postgresql.auth.database .Values.postgresql.auth.database -}}
        {{- else -}}
            {{- .Values.postgresql.auth.database -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.database -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "midpoint.database.username" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.global.postgresql }}
        {{- if .Values.global.postgresql.auth }}
            {{- coalesce .Values.global.postgresql.auth.username .Values.postgresql.auth.username -}}
        {{- else -}}
            {{- .Values.postgresql.auth.username -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.username -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Secret Name
*/}}
{{- define "midpoint.database.secretName" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.global.postgresql }}
        {{- if .Values.global.postgresql.auth }}
            {{- if .Values.global.postgresql.auth.existingSecret }}
                {{- tpl .Values.global.postgresql.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "midpoint.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "midpoint.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "midpoint.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (printf "%s-externaldb" (include "common.names.fullname" .)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a MidPoint authentication credentials secret object should be created
*/}}
{{- define "midpoint.createSecret" -}}
{{- if or (not .Values.existingSecret) (and (not .Values.smtpExistingSecret) .Values.smtpPassword) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the MidPoint Secret Name
*/}}
{{- define "midpoint.secretName" -}}
{{- if .Values.existingSecret }}
    {{- printf "%s" (tpl .Values.existingSecret .) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the SMTP Secret Name
*/}}
{{- define "midpoint.smtpSecretName" -}}
{{- if .Values.smtpExistingSecret }}
    {{- printf "%s" (tpl .Values.smtpExistingSecret .) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Sysctl set a property if less than a given value
*/}}
{{- define "midpoint.sysctl.ifLess" -}}
CURRENT="$(sysctl -n {{ .key }})"
DESIRED="{{ .value }}"
if [[ "$DESIRED" -gt "$CURRENT" ]]; then
    sysctl -w {{ .key }}={{ .value }}
fi
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "midpoint.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "midpoint.validateValues.database" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/* Validate values of MidPoint - Database */}}
{{- define "midpoint.validateValues.database" -}}
{{- if and (not .Values.postgresql.enabled) (or (empty .Values.externalDatabase.host) (empty .Values.externalDatabase.port) (empty .Values.externalDatabase.database)) -}}
midpoint: database
   You disable the PostgreSQL installation but you did not provide the required parameters
   to use an external database. To use an external database, please ensure you provide
   (at least) the following values:

       externalDatabase.host=DB_SERVER_HOST
       externalDatabase.port=DB_SERVER_PORT
       externalDatabase.database=DB_NAME
{{- end -}}
{{- end -}}


{{/*
Return true if a configmap object should be created for midpoint
*/}}
{{- define "midpoint.createConfigmap" -}}
    {{- true -}}
{{- end -}}

{{/*
Return the MidPoint Configmap
*/}}
{{- define "midpoint.configmap" -}}
    {{ printf "%s-configuration" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Return the MidPoint Customized Schema Objects configmap
*/}}
{{- define "midpoint.configmap.schema" -}}
    {{ printf "%s-schema" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Return the MidPoint Schema Path 
*/}}
{{- define "midpoint.configmap.schema.path" -}}
{{- if .Values.midpoint.schema.enabled }}
    {{- printf "%s" (tpl .Values.midpoint.schema.sourcePath .) -}}
{{- else -}}
    {{- printf "" -}}
{{- end -}}
{{- end -}}


{{/*
Return the MidPoint Customized SQL updates configmap
*/}}
{{- define "midpoint.configmap.sql" -}}
    {{ printf "%s-sql" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Return the MidPoint SQL Path 
*/}}
{{- define "midpoint.configmap.sql.path" -}}
{{- if .Values.midpoint.sql.enabled }}
    {{- printf "%s" (tpl .Values.midpoint.sql.sourcePath .) -}}
{{- else -}}
    {{- printf "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the MidPoint Post Initial Objects configmap
*/}}
{{- define "midpoint.configmap.poi" -}}
    {{ printf "%s-poi" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Return the MidPoint Connector Configmap
*/}}
{{- define "midpoint.configmap.connectors" -}}
    {{ printf "%s-connectors" (include "common.names.fullname" .) }}
{{- end -}}