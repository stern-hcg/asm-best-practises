#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "Check from hello-proxy-deploy:"
proxy_pod=$(k get pod -l app=hello-proxy-deploy -n hello -o jsonpath={.items..metadata.name})
echo "  proxy_pod=$proxy_pod"
k exec $proxy_pod -c hello-proxy-deploy -n hello -- curl -s http://http-hello-svc:8001/hello/feuyeux
echo
k exec $proxy_pod -c hello-proxy-deploy -n hello -- curl -s localhost:7001/hello/feuyeux
echo

echo "Check from http-hello-deploy v3:"
v3_pod=$(k get pod -l app=http-hello-deploy -n hello -o jsonpath='{.items[2].metadata.name}')
k exec $v3_pod -c http-hello-deploy -n hello -- curl -s localhost:8001/hello/feuyeux

echo
k exec $proxy_pod -c hello-proxy-deploy -n hello -- curl -s http://http-hello-svc:8001/bye
echo
k exec $proxy_pod -c hello-proxy-deploy -n hello -- curl -s localhost:7001/bye
echo
k exec $v3_pod -c http-hello-deploy -n hello -- curl -s localhost:8001/bye