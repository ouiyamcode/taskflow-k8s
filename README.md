# Taskflow Kubernetes Project

This project implements a microservices-based application deployed on Kubernetes, with a strong focus on **network isolation**, **controlled communication**, and **Kubernetes best practices**.

The system is split into two namespaces (`taskflow-frontend` and `taskflow-backend`) and relies on **NetworkPolicies**, **sidecars**, and **service-based communication** to enforce security, scalability, and observability.

---

## Architecture Diagram

The following diagram represents the **actual implemented architecture**, based on the deployed Kubernetes manifests and validated through runtime tests.  
All services are shown with their **container image and exposed port** (`image:port`).

```mermaid
graph LR
  %% External access
  User -->|NodePort 30080| Frontend

  %% Frontend namespace
  subgraph taskflow_frontend["taskflow-frontend namespace"]
    Frontend[frontend<br/>nginx:1.25-alpine:80]
    Gateway[api-gateway<br/>nginx:1.25-alpine:3000]

    Frontend -->|HTTP 80→3000| Gateway
  end

  %% Backend namespace
  subgraph taskflow_backend["taskflow-backend namespace"]

    %% Auth pod
    subgraph AuthPod["auth pod"]
      Auth[auth<br/>hashicorp/http-echo:5000]
      Audit[audit sidecar<br/>hashicorp/http-echo:9090]
      Auth -->|localhost| Audit
    end

    %% Tasks pod
    subgraph TasksPod["tasks pod"]
      Tasks[tasks<br/>hashicorp/http-echo:8081]
      Health[health-checker sidecar<br/>curlimages/curl]
    end

    %% Standalone backend services
    subgraph BackendServices["backend services"]
      Metrics[metrics<br/>hashicorp/http-echo:5001]
      Notifications[notifications<br/>hashicorp/http-echo:3001]
    end

    %% Communications
    Gateway -->|HTTP 3000→5000| Auth
    Gateway -->|HTTP 3000→8081| Tasks
    Gateway -->|HTTP 3000→3001| Notifications
    Gateway -->|HTTP 3000→5001| Metrics

    Tasks -->|HTTP 8081→5000| Auth
    Health -->|HTTP 5001 (external service)| Metrics
  end


