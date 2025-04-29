Recent ML models (whether LLMs or not) can often require more resources than available on a laptop.

For experiments and research, it would be very useful to be able to serve ML models running on machines with proper computing resources (RAM/CPU/GPU) and run remote inference through gRPC/HTTP.

Note: I didn't include [skypilot](https://docs.skypilot.co/en/latest/overview.html) but it also looks promising.

# Specs
- support for batch inference
- open source
- actively maintained
- async and sync API
- K8s compatible
- easy to deploy a new model
- support arbitrary ML models
- gRPC/HTTP APIs

# Candidates
## [vLLM](https://docs.vllm.ai/en/latest/)
Pros:
- trivial do deploy and use

Cons:
- only support recent ML models

## [Kubeflow](https://www.kubeflow.org/docs/started/introduction/) + [Kserve](https://www.kubeflow.org/docs/external-add-ons/kserve/)
Pros:
- tailored for k8s and serving
- kube pipeline for training

Cons:
- Kserve is not framework agnostic: inference runtimes need to be implemented to be available (currently there are a lot of them available, but that imply latency when a new framework/lib pops up)

## [BentoML](https://bentoml.com/)
Pros:
- agnostic/flexible
Cons:
- only a shallow [integration with k8s](https://github.com/bentoml/Yatai)

## [Nvidia triton](https://developer.nvidia.com/triton-inference-server)
Cons:
- only for GPU/Nvidia backed models, no traditional models


## [TorchServer](https://pytorch.org/serve/)
Cons:
	- limited maintainance
	- only for torch models, not traditional ML


## [Ray](https://docs.ray.io/en/latest) + [Ray Serve](https://docs.ray.io/en/latest/serve/index.html)
Pros:
- fits very well with [K8s](https://docs.ray.io/en/latest/serve/production-guide/kubernetes.html) (from a user standpoint at least). Will allow to easily elastically deploy ML models (a single model) and apps (a more complex ML workflow)
- inference framework agnostic 
- [vLLM support](https://docs.ray.io/en/latest/serve/llm/overview.html)
- seems to be the most popular/active project at the moment
- support training + generic data processing: tasks and DAG of taks. Very well suited to ML experiments/research
- tooling/monitoring tools to monitor inference + metrics for grafana

Cons:
- a ray operator node is needed to manage worker nodes (can we use keda or something else to shut it down when not needed ?)
- ray's flexibility/agnosticity comes at the cost of some minor boilerplate code to be implemented (to expose a HTTP service for instance)


# Conclusion

Ray comes in the first place, followed by Kserve.
