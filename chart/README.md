# Valheim-Server Helm Chart
Deploy your own Valheim server in Kubernetes

Please also see https://adaliszk.io/valheim-server/kubernetes


## Prerequisites
* Kubernetes with extensions/v1beta1 available
* A persistent storage resource and RW access to it
* Kubernetes StorageClass for dynamic provisioning


## Configuration
By default, this chart will create persistent storage for the server, backups,
and for the logs to be shared.

In addition, by default, pod `securityContext.fsGroup` is set to `1001`. This
is the user/group that the Server container runs as, and is used to
enable local persistent storage.

For a more robust solution supply helm install with a custom values.yaml
You are also required to create the StorageClass resource ahead of time:
```
kubectl create -f /path/to/storage_class.yaml
```

