# Wait for JupyterLab to open its port; give up early if it exits (bad image etc.)
echo "Waiting for JupyterLab to open port ${port}..."
for ((i = 0; i < 1200; i++)); do
  if port_used "${host}:${port}"; then
    echo "Discovered JupyterLab listening on port ${port}!"
    sleep 2
    return 0 2>/dev/null || true
    break
  fi
  if [[ -n "${SCRIPT_PID:-}" ]] && ! kill -0 "${SCRIPT_PID}" 2>/dev/null; then
    echo "JupyterLab exited before opening port ${port}; see the errors above in output.log." >&2
    clean_up 1
  fi
  sleep 0.5
done
if ! port_used "${host}:${port}"; then
  echo "Timed out waiting for JupyterLab to open port ${port}!" >&2
  clean_up 1
fi
