# Debugging container for Kubernetes

## How to use the Image

If you want to debug an existing Pod, simply attach to it like this:

```shell
kubectl debug -it -n <NAMESPACE> <POD> --image=ghcr.io/boomer41/debug-container --image-pull-policy=Always
```

You are then dropped into a shell - by default `zsh`.

## Usage

### Get Root

It is good practice to run Pods as non-root.
However, debugging sometimes needs root.

This images comes with a privilege escalation **by design**, to facilitate easy root access.
If you are not root, simply type `get-root`, and you'll be dropped into a new root shell.

### Dump the Pod's Network Traffic

Sometimes there is just the need to see exactly *what* is being handled by the Pod.
This image contains an easy way to push the traffic to your local computer in order to decode it with Wireshark.

To dump the traffic, follow those steps:

1. Ensure you are root. If not, execute `get-root`.
2. Execute `tcpdump-port`. By default, it listens to port `10000/tcp`.
   If that port is already in use, select another port by using `--port <PORT>`.
3. In a second shell: Create a Port-Forward to the Pod: `kubectl port-forward -n <NAMESPACE> pods/<POD> 10001:10000`.
   This opens port `10001/tcp` on your **local machine** and forwards it to the pod's port `10000/tcp`.
   Remember to adjust this command if you had to use a different port in step 2!
4. In a third shell: Launch Wireshark.
   Remember to adjust the port here if you had to use a different **local** port in step 3!

   For Linux: `nc -v 127.0.0.1 10001 | wireshark -k -i -`

   For macOS: `nc -v 127.0.0.1 10001 | /Applications/Wireshark.app/Contents/MacOS/Wireshark -k -i -`

If you want to see all parameters of the program, execute `tcpdump-port --help`.

