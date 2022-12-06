{{- define "valheim-server.name" -}}
{{ .Release.Name }}
{{- end }}

{{- define "valheim-server.selectorLabels" }}
release: {{ .Release.Name | quote }}
service: "game-server"
{{- end }}

{{- define "valheim-server.labels" }}
type: "game-server"
game: "valheim"
{{- end }}

{{- define "valheim-server.annotations" }}
adaliszk.io/chart: "valheim-server"
adaliszk.io/type: "game-server"
adaliszk.io/game: "valheim"
{{- end }}

{{- define "valheim-server.storageClass" -}}
{{ .Values.global.storageClass }}
{{- end }}

{{- define "valheim-server.storageSize" -}}
{{ .Values.persistence.size }}
{{- end }}

{{- define "valheim-server.image" -}}
{{ .Values.image.registry }}/{{ .Values.image.repository }}/{{ .Values.image.name }}:{{ .Values.image.tag }}
{{- end }}

{{- define "valheim-server.imagePullPolicy" -}}
Always
{{- end }}
