#!/bin/bash
cat <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
  labels:
    name: prometheus-config
data:
  prometheus.yml: |-
    global:
      scrape_interval: 80s
      scrape_timeout: 30s
      evaluation_interval: 75s
    rule_files:
      - /etc/config/*.rules
    alerting:
      alertmanagers:
      - scheme: http
        path_prefix: "alertmanager/"
        static_configs:
        - targets:
          - "alertmanager.monitoring.svc:9093"
    scrape_configs:
      - job_name: 'fk-traun-node'
        metrics_path: '/node/metrics'
        static_configs:
          - targets: ['monitoring.freikirche-traun.at']
            labels:
              longterm: "true"
      - job_name: 'fk-traun-mysql'
        metrics_path: '/mysql/metrics'
        static_configs:
          - targets: ['monitoring.freikirche-traun.at']
            labels:
              longterm: "true"
      - job_name: 'fk-traun-nginx'
        metrics_path: '/nginx/metrics'
        static_configs:
          - targets: ['monitoring.freikirche-traun.at']
            labels:
              longterm: "true"
      - job_name: 'nas'
        static_configs:
          - targets: ['192.168.1.125:9100']
            labels:
              longterm: "true"
      - job_name: 'ai'
        static_configs:
          - targets: ['192.168.1.138:9100']
            labels:
              longterm: "true"
      - job_name: 'screen'
        static_configs:
          - targets: ['192.168.1.178:9100']
            labels:
              longterm: "true"
      - job_name: 'backup-node'
        static_configs:
          - targets: ['192.168.1.61:9100']
            labels:
              longterm: "true"
      - job_name: 'ssl'
        static_configs:
          - targets: ['192.168.1.162:9100']
            labels:
              longterm: "true"
      - job_name: 'ssl-nginx'
        static_configs:
          - targets: ['192.168.1.162:9113']
            labels:
              longterm: "true"
      - job_name: 'ssl-certbot'
        static_configs:
          - targets: ['192.168.1.162:9099']
            labels:
              longterm: "true"
      - job_name: 'ssl-fail2ban'
        static_configs:
          - targets: ['192.168.1.162:9191']
            labels:
              longterm: "true"
      - job_name: 'ups'
        static_configs:
          - targets: ['192.168.1.30:9780']
            labels:
              longterm: "true"
      - job_name: 'nas-disks'
        static_configs:
          - targets: ['192.168.1.125:9633']
            labels:
              longterm: "true"
      - job_name: 'ai-disks'
        static_configs:
          - targets: ['192.168.1.138:9633']
            labels:
              longterm: "true"
      - job_name: 'backup-disks'
        static_configs:
          - targets: ['192.168.1.61:9633']
            labels:
              longterm: "true"
      - job_name: 'sar-server-node'
        metrics_path: '/metrics/node'
        static_configs:
          - targets: ['$SERVER']
            labels:
              longterm: "true"
        basic_auth:
          username: '$BASICAUTHUSER'
          password: '$BASICAUTHPASS'
      - job_name: 'sar-server-nginx'
        metrics_path: '/metrics/nginx'
        static_configs:
          - targets: ['$SERVER']
            labels:
              longterm: "true"
        basic_auth:
          username: '$BASICAUTHUSER'
          password: '$BASICAUTHPASS'
      - job_name: 'sar-server-fail2ban'
        metrics_path: '/metrics/fail2ban'
        static_configs:
          - targets: ['$SERVER']
            labels:
              longterm: "true"
        basic_auth:
          username: '$BASICAUTHUSER'
          password: '$BASICAUTHPASS'
      - job_name: 'sar-server-certbot'
        metrics_path: '/metrics/certbot'
        static_configs:
          - targets: ['$SERVER']
            labels:
              longterm: "true"
        basic_auth:
          username: '$BASICAUTHUSER'
          password: '$BASICAUTHPASS'
      - job_name: 'homeassistant'
        metrics_path: '/api/prometheus'
        bearer_token: '$HOMEASSISTANT_TOKEN'
        static_configs:
          - targets: ['homeassistant.homeassistant.svc:8123']
            labels:
              longterm: "true"
      - job_name: 'opendtu'
        scrape_interval: 60s
        scrape_timeout: 30s
        metrics_path: '/api/prometheus/metrics'
        static_configs:
          - targets: ['192.168.1.146:80']
            labels:
              longterm: "true"
      - job_name: 'prometheus'
        static_configs:
          - targets: ['prometheus.monitoring.svc:9090']
      - job_name: 'prometheus-backup'
        static_configs:
          - targets: ['prometheus-backup.monitoring.svc:9090']
			- job_name: 'internet_latency'
				metrics_path: /probe
				params:
					module: [icmp]
				static_configs:
					- targets:
						- 1.1.1.1    # Cloudflare
						- 8.8.8.8    # Google DNS
            labels:
              longterm: "true"
				relabel_configs:
					- source_labels: [__address__]
						target_label: __param_target
					- source_labels: [__param_target]
						target_label: instance
					- target_label: __address__
            replacement: blackbox-exporter.monitoring.svc:9115
      - job_name: 'blackbox'
        metrics_path: /probe
        params:
          module: [http_2xx]
        static_configs:
          - targets:
            - https://freikirche-traun.at
            - https://sar-voest.duckdns.org
            - https://$SERVER/up
            labels:
              longterm: "true"
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: blackbox-exporter.monitoring.svc:9115
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https
      - job_name: 'kubernetes-nodes'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/\${1}/proxy/metrics
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: \$1:\$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name
        - source_labels: [__meta_kubernetes_pod_node_name]
          action: replace
          target_label: kubernetes_pod_node_name
      - job_name: 'kubernetes-cadvisor'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/\${1}/proxy/metrics/cadvisor
      - job_name: 'kubernetes-service-endpoints'
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: \$1:\$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name

  fk.rules: |-
    groups:
      - name: fk
        rules:
          - alert: nginxDown
            expr: nginx_up{instance="monitoring.freikirche-traun.at:80"} != 1
            for: 60m
            labels:
              severity: slack
              channel: '#alerts'
            annotations:
              title: "nginx is down"
              description: "@here - nginx exporter is not reporting, or is down. check it out."
          - alert: mysqlDown
            expr: mysql_up{instance="monitoring.freikirche-traun.at:80"} != 1
            for: 5m
            labels:
              severity: slack
              channel: '#alerts'
            annotations:
              title: "mysql is down"
              description: "@here - mysql exporter is not reporting, or is down. check it out."
          - alert: nodeDfLow
            expr: (1 - (node_filesystem_avail_bytes{instance="monitoring.freikirche-traun.at:80",fstype!="tmpfs"} / node_filesystem_size_bytes{instance="monitoring.freikirche-traun.at:80",fstype!="tmpfs"})) * 100 > 85 AND (1 - (node_filesystem_avail_bytes{instance="monitoring.freikirche-traun.at:80",fstype!="tmpfs"} / node_filesystem_size_bytes{instance="monitoring.freikirche-traun.at:80",fstype!="tmpfs"})) * 100 < 95
            for: 5m
            labels:
              severity: slack
              channel: '#alerts'
            annotations:
              title: "Space is getting low"
              description: "@here - Disk free on {{ \$labels.mountpoint }} is getting low: {{ \$value }}. check it out."
          - alert: nodeDfCritical
            expr: (1 - (node_filesystem_avail_bytes{instance="monitoring.freikirche-traun.at:80",fstype!="tmpfs"} / node_filesystem_size_bytes{instance="monitoring.freikirche-traun.at:80",fstype!="tmpfs"})) * 100 >= 95
            for: 5m
            labels:
              severity: slack
              channel: '#alerts'
            annotations:
              title: "Space is getting critically low"
              description: "@here - Disk free on {{ \$labels.mountpoint }} is getting low: {{ \$value }}. check it out."
          - alert: nodeMem
            expr: ((node_memory_MemTotal_bytes{instance="monitoring.freikirche-traun.at:80"} - node_memory_MemFree_bytes{instance="monitoring.freikirche-traun.at:80"}  - node_memory_Buffers_bytes{instance="monitoring.freikirche-traun.at:80"} - node_memory_Cached_bytes{instance="monitoring.freikirche-traun.at:80"}) / node_memory_MemTotal_bytes{instance="monitoring.freikirche-traun.at:80"}) > 0.8
            for: 5m
            labels:
              severity: slack
              channel: '#alerts'
            annotations:
              title: "Free Memory is getting low."
              description: "@here - Free memory is low: {{ \$value }}."

  my.rules: |-
    groups:
      - name: home
        rules:
          - alert: CertExpiration
            expr: certbot_cert_expiry_countdown{name="tevnan.duckdns.org"} < 172800
            for: 5m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Certificat expiration"
              description: "{{ $labels.name }} cert will expire in 2 days"
          - alert: CertValidity
            expr: certbot_cert{name="tevnan.duckdns.org",certbot_cert="VALID"} != 1
            for: 5m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Certificat not valid"
              description: "{{ $labels.name }} cert is not valid"
          - alert: RaidDegraded
            expr: node_md_disks{state="failed"} != 0
            for: 5m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Raid Array degraded"
              description: "{{ $labels.device}} on {{ $labels.job }} has failed disks."
          - alert: DehumidifierWaterFull
            expr: sum(hass_switch_state{friendly_name="dehumidifier  Switch"} == 1) and sum(hass_sensor_power_w{friendly_name="dehumidifier  Active power"} < 20)
            for: 5m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Dehumidifier is on but not consuming electricity"
              description: "The water container for the dehumidifier is probably full. please empty it."
          - alert: TempratureSensorBatteryOut
            expr: rate(hass_sensor_temperature_celsius[720m])*100 == 0
            for: 120m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Check Temprature Sensor Battery"
              description: "Battery might be empty on the Temperature Sensor {{ \$labels.friendly_name }}"
          - alert: TempratureSensorMissing
            expr: absent(hass_sensor_temperature_celsius) == 1
            for: 60m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Temperature Sensor Metrics Missing"
              description: "Metrics for the temperature sensors from home assistant are missing"
          - alert: ExporterDown
            expr: up != 1
            for: 30m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Exporter not up"
              description: "Exporter job {{ \$labels.job }} is failing"
          - alert: HomeAssistantHangUp
            expr: rate(hass_sensor_power_w{friendly_name="refrigerator Electricalmeasurement"}[30m])*100 == 0
            for: 120m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Check HomeAssistantHangUp"
              description: "Zigbee GW might be foobar"
          - alert: PowerConsumptionHigh
            expr: hass_sensor_power_w{friendly_name="Mean AMIS power in"} > 2500
            for: 180m
            labels:
              severity: slack
              channel: '#private-alerts'
            annotations:
              title: "Power Consumption high"
              description: "Power usage in the house is high"
EOF
