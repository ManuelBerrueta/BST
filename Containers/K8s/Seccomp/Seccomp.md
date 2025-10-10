# Seccomp (Secure Computing Mode)

## What is Seccomp?

Seccomp is a Linux kernel feature that filters system calls (syscalls) to reduce the attack surface. It acts as a syscall filter, allowing only approved system calls and blocking others.
It uses Berkeley Packet Filter (BPF) programs to enforce these rules.
By limiting syscalls, seccomp helps prevent dangerous syscall and exploitation of kernel vulnerabilities by malicious actors.

## How Kubernetes Uses Seccomp
Kubernetes integrates seccomp profiles to control syscall access for Pods and containers:

- **Pod Level**: Apply a seccomp profile to the entire Pod via spec.securityContext.seccompProfile.
- **Container Level**: Apply profiles individually to containers using spec.containers[*].securityContext.seccompProfile.
- **Init/Ephemeral Containers**: Profiles can also be applied to these container types


## Types of Seccomp Profiles

- **`Unconfined`**: No restrictions; all syscalls allowed.
- **`RuntimeDefaul`t**: Uses the container runtime’s default seccomp profile (e.g., containerd blocks ~40+ syscalls).
- **`Localhos`t**: Custom JSON profile stored on the node for fine-grained control.

---    
## Pod Manifest Example
- Pod-Level seccomp Profile: The RuntimeDefault profile applies to all containers unless overridden. It blocks dangerous syscalls by default.
- Container-Level seccomp Profile: Localhost: Uses a custom JSON profile stored on the node for fine-grained control.
Unconfined: Disables seccomp filtering (use only for troubleshooting).
- Why seccomp matters: Restricts Linux syscalls to reduce attack surface and prevent kernel-level exploits.

```yaml
# This manifest defines a Pod with two containers and demonstrates seccomp usage.
apiVersion: v1
kind: Pod
metadata:
  name: seccomp-demo-pod        # Name of the Pod
spec:
  # Apply a seccomp profile at the Pod level
  securityContext:
    seccompProfile:
      type: RuntimeDefault      # Use the container runtime's default seccomp profile for the entire Pod
  containers:
    - name: nginx-container
      image: nginx:latest       # Runs an NGINX web server
      securityContext:
        seccompProfile:
          type: Localhost       # Apply a custom seccomp profile for this container
          localhostProfile: profiles/nginx-seccomp.json  # Path to custom profile on the node
    - name: busybox-container
      image: busybox:latest     # Lightweight container for debugging
      command: ["sleep", "3600"] # Keeps the container running
      securityContext:
        seccompProfile:
          type: Unconfined      # No syscall restrictions for this container (not recommended for production)
```
### Custom Seccomp Profile
This is the `nginx-seccomp.json` seccomp profile referenced in the above Pod manifest. It shows an example on how you can customize the profile to fit your needs

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",  // Block all syscalls by default
  "architectures": [
    "SCMP_ARCH_X86_64",
    "SCMP_ARCH_X86",
    "SCMP_ARCH_X32"
  ],
  "syscalls": [
    {
      "names": ["accept", "listen", "connect", "read", "write"],
      "action": "SCMP_ACT_ALLOW"  // Allow essential networking and I/O syscalls
    },
    {
      "names": ["clone", "fork", "execve"],
      "action": "SCMP_ACT_ERRNO"  // Explicitly block process creation
    }
  ]
}
```

---    
## Enabling Seccomp in AKS
To enable using az cli:
```sh
az aks update \
  --resource-group <RESOURCE_GROUP> \
  --name <CLUSTER_NAME> \
  --enable-seccomp-default
```

To verify:
```sh
az aks show --resource-group <your-resource-group> --name <your-cluster-name> --query "securityProfile.seccompProfile" --output jsonc
```
