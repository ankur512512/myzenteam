# Assignment

## Quick-setup:

### Pre-requisites:

This project is tested on below configuration.

- Cloud VM instance with public-ip (4GB memory)
- Debian GNU/Linux 11
- Sub domain name mapped to your VM's public ip
- Docker (v20.10.5)
- kubernetes (v1.19.1)
- Helm (v3.8.2)
- kind (v0.12.0)

Please make sure that your Cloud-VM has ingress ports open for both HTTP and HTTP/S (80 and 443).
SSH into your Cloud-VM having public-ip with `root` user and install `docker, helm, kubectl and kind` using below command:

```bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install docker.io helm kubectl -y

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/bin/kind
```

Now create the k8s cluster using below kind command:

```bash
kind create cluster --name certmanager --image kindest/node:v1.19.1
```

It will take some time and once all the pods in `kube-system` namespace are ready, proceed with below steps:

1. Git clone this project and cd into it using:

   ```bash
   git clone https://github.com/ankur512512/myzenteam.git
   cd myzenteam
   ```

2. Export `hostname` variable by assigning it your subdomain-name:
   ```bash
   export hostname="<your-subdomain>" ## For-ex: export hostname="ankur.servehttp.com"
   ```
   :red_circle: Please note that the next script will port-forward ports 443 and 80. So please make sure you don't run anything else on those ports inside your VM host.   

3. Run the below bash script to set everything up for you:

   ```bash
   ./startup.sh
   ```

4. The above script contains some basic helm and k8s related commands and after deploying everything, it will test our application url in the end using `curl` command. To check it manually use the below curl command:

   ```bash
   curl -L https://<your-domain-name> ## For-ex: curl -L https://ankur.serverhttp.com
   ```
   Or you can also use your browser to visit the url. It should look like this:

   ![image](https://user-images.githubusercontent.com/12583640/167422481-b5b48e7b-2e40-47d9-8015-8291af8793e6.png)

5. Once you're done with the testing, you can tear-down/destroy the Infrastructure that you created using below command:
   
   ```bash
   ./teardown.sh
   ```
   
   
## Detailed Explaination:

Here is the detailed explaination of how this project is operating.

1. Golang code used is [this](https://github.com/golang/example/blob/master/outyet/main.go) with one small change:

   a. Converted the Golang version from [1.4](https://github.com/golang/example/blob/master/outyet/main.go#L36) to an environment variable named `GO_TAG`

   This application will tell us if the given Golang version tag is released yet or not. By default, it will pick up `1.7` but you can change it in values.yaml file [here](https://github.com/ankur512512/myzenteam/blob/master/helm/values.yaml#L19), before deploying the helm chart.

2. Docker build and push is handled via `github-actions` in the repo itself. To see a demo, check this [link](https://github.com/ankur512512/myzenteam/runs/6352383615?check_suite_focus=true). This will build and push the docker image to my personal [repo](https://hub.docker.com/layers/myzenteam/ankur512512/myzenteam/1.0/images/sha256-f5542c608161832ad0722e277c748f34d8d56f2f8c1735276ada863e38f0addd?context=explore) hosted on `Dockerhub` which is available publicly for k8s to use.

3. We have used [cert-manager](https://www.jetstack.io/blog/cert-manager-cncf/) from `jetstack` for TLS Offloading purpose.

4. Then the required addons are installed: `nginx-ingress` *(for ingress)* and `metrics-server` *(for hpa)*.
   As we are hosting k8s locally on the VM, we won't get any `LoadBalancer IP`, so we are doing port-forwarding to access our cluster.

5. Now our Application helm chart is deployed; for which a TLS certificate is generated automatically.

6. We then wait for the application pod to get ready before we can run curl command against it.

7. All done, now we can check our application by using below `curl` command or by visiting it on a web-browser:

   `curl -L https://<your-subdomain-name>`

### Task Achievements:

1. **Container minimalization & security**: To keep the container size minimum, we have used `alpine` image instead of ubuntu or centos. For security, we have used a non-root user called `appuser` instead of the default `root` user. Also, image is scanned automatically for any vulnerabilities in github-actions after building the image, before pushing it to the repo.

2. **Continous Integration**: Github-actions are used for this purpose which automatically build the image, then scan the image for any vulnerabilities and then push the image to Dockerhub.

3. **TLS Offloading**: We have used `cert-manager` from jetstack. Reason of using this solution is because it's part of CNCF so it's standardized and it also provides an automated solution to deploy/renew certificates. With the use of a simple `annotation` in ingress resource and a `certificate` resource, we can get our certificates creation/renewel automated.

4. **Automation/Infrastructure as Code**: This is achieved using helm charts and a little bit of bash scripts.

5. **Resiliency**: Our application is made resilient using `HPA (Horizontal Pod Autoscaler)`, which will automatically scale up the pods based on the memory/cpu utilization.
