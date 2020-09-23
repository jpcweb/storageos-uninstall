# Uninstall StorageOS

### Informations
StorageOS => [Link](https://docs.storageos.com)

This shell script helps you to remove StorageOS from your **Kubernetes** cluster.
It's also useful if you want to reinstall it.
Tested with StorageOS v2.2.0 and Kubernetes v1.18.

```bash
# If you want to remove the operator you'll need the storageos-operator.yaml
# You can find this file in the deploy-storageos-cluster.sh provided by StorageOS
./remove_storageos.sh
```
