<h2>python flask demo</h2>
> ### flask demo summary
> - sqlite3 
> - static html template(j2)
> - binary file(images)
> - logn libs


> ### docker build info
> - docker login
> - docker build -t ericxiwang/flask .
> - docker tag <image-id> ericxiwang/flask:<build-id>
> - docker push erixiwang/flask:<build-id>
> 
> 
> 
> 
> ### k8s kustomization tree
> - default.conf      ----- nginx conf file, port 8080
> - deployment.yaml   ------ flask/nginx containers inside, port 8080
> - ingress.yaml      ------ port 8080
> - service.yaml      ------ port 8080
> - kustomization.yaml------ k8s confi management
> 
>> - kubectl apply -k <current_folder>
>> - kubectl get -k .
>> - kubectl describe -k .
>> - kubectl diff -k .
>> - kubectl delete -k .

> 
> - kubectl port-forward --address 0.0.0.0 service/flask-demo 8080:8080