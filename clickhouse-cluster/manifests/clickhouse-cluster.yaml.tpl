apiVersion: "clickhouse.altinity.com/v1"
kind: "ClickHouseInstallation"
metadata:
  name: "${name}"
  namespace: "${namespace}"
spec:
  configuration:
    users:
      ${user}/password: ${password}
      # to allow access outside from kubernetes
      ${user}/networks/ip: 0.0.0.0/0
    zookeeper:
        nodes:
        - host: zookeeper.${zookeeper_namespace}
          port: 2181
    clusters:
      - name: "${name}"
        layout:
          shardsCount: 1
          replicasCount: 1
        templates:
          podTemplate: clickhouse-stable
          volumeClaimTemplate: data-volume-template
          serviceTemplate: internal-service-template
  templates:
    serviceTemplates:
      - name: internal-service-template
        spec:
          type: ClusterIP
          ports:
            - name: http
              port: 8123
              targetPort: 8123
            - name: tcp
              port: 9000
              targetPort: 9000
    podTemplates:
      - name: clickhouse-stable
        spec:
          containers:
          - name: clickhouse
            image: altinity/clickhouse-server:23.8.8.21.altinitystable
    volumeClaimTemplates:
      - name: data-volume-template
        spec:
          storageClassName: gp3-encrypted
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100Gi
