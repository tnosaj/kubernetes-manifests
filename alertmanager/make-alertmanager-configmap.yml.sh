#!/bin/bash
cat << EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: alertmanager
  namespace: monitoring
data:
  config.yml: |-
    global:
      resolve_timeout: 5m
      http_config:
        tls_config:
          insecure_skip_verify: true
    route:
      receiver: slack
      group_by: [alertname,job]
      group_interval: 5m
      repeat_interval: 5h
    receivers:
    - name: slack
      slack_configs:
      - api_url: '$SLACK_API_URL'
        username: 'Alertmanager'
        channel: '{{ template "slack.channel" . }}'
        send_resolved: true
        title: |-
          [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
          {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
            {{" "}}(
            {{- with .CommonLabels.Remove .GroupLabels.Names }}
              {{- range \$index, \$label := .SortedPairs -}}
                {{ if \$index }}, {{ end }}
                {{- \$label.Name }}="{{ \$label.Value -}}"
              {{- end }}
            {{- end -}}
            )
          {{- end }}
        text: >-
          {{ with index .Alerts 0 -}}
            :chart_with_upwards_trend: *<{{ .GeneratorURL }}|Graph>*
            {{- if .Annotations.runbook }}   :notebook: *<{{ .Annotations.runbook }}|Runbook>*{{ end }}
          {{ end }}
    
          *Alert details*:
    
          {{ range .Alerts -}}
            *Alert:* {{ .Annotations.title }}{{ if .Labels.severity }} - \`{{ .Labels.severity }}\`{{ end }}
          *Description:* {{ .Annotations.description }}
          *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* \`{{ .Value }}\`
            {{ end }}
          {{ end }}
    templates:
    - /etc/alertmanager-templates/*.tmpl
EOF
