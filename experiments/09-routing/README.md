# Routing

## Concept

- Send unfiltered logs to
   - S3
   - routing to transform/attribute
      - delete params
      - send to datadog


## Scratchpad

```sh
ls 0*.json | grep -v 0330-bbca956e-3030-4466-9949-18ce0560f14b-log.json
# 0330-bbca956e-3030-4466-9949-18ce0560f14b-log.json
ls 0*.json | grep -v 0330-bbca956e-3030-4466-9949-18ce0560f14b-log.json | xargs -I {} mv {} delete/
ls 1*.json | grep -v 0330-bbca956e-3030-4466-9949-18ce0560f14b-log.json | xargs -I {} mv {} delete/
```

## Comparing logs

```sh
# raw - copied directly from k8s using kubectl logs api-web pod
# processed - copied from 0330-bbca956e*.json (in S3)
echo "nodejs 23.3.0" > .tool-versions
npx jsondiffpatch raw.json processed.json
```

```diff
{
   duration: 31.81 => 24.51
   view: 6.78 => 6.1
   db: 5.35 => 5.55
   timestamp: "2025-04-03T15:45:37.000+04:00" => "2025-04-03T09:00:16.039+04:00"
   logged_at: "2025-04-03 15:45:37.000" => "2025-04-03 09:00:16.039"
   correlation_id: "d084b5da-0911-4ef5-a7e1-f595c3afbb66" => "f098dba4-2cff-4e45-95af-41046675fb8b"
+  time: "2025-04-03T05:00:16.040125975Z"
+  _p: "F"
+  kubernetes: {
+    "pod_name": "api-web-6b549f445-mhcnz",
+    "namespace_name": "api",
+    "host": "ip-10-161-155-238.eu-west-1.compute.internal",
+    "container_name": "web",
+    "container_image": "302790928390.dkr.ecr.eu-west-1.amazonaws.com/api:2025-04-02-c46872b-14223878625"
+  }
+  is_kube_hydrated: "YES"
+  hostname: "ip-10-161-155-238.eu-west-1.compute.internal"
}
```

### New fields in processed logs

- `time`: 2025-04-03T05:00:16.040125975Z
- `_p`: "F" - this maybe something fluent sets
- `kubernetes`: {...}
- `is_kube_hydrated`: "YES"
- `hostname`: "ip-10-161-155-238.eu-west-1.compute.internal"
