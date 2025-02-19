/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_id_parts = split("/", var.cluster_id)
  cluster_name     = local.cluster_id_parts[5]
  cluster_location = local.cluster_id_parts[3]
  project_id       = local.cluster_id_parts[1]
}

data "google_client_config" "default" {}

data "google_project" "project" {
  project_id = local.project_id
}

data "google_container_cluster" "gke_cluster" {
  project  = local.project_id
  name     = local.cluster_name
  location = local.cluster_location
}

resource "helm_release" "nemo" {
  count     = var.recipe == "gke-nccl" ? 0 : 1
  name      = "nemo"
  provider  = helm
  version     = "0.7.0"
  chart     = "${path.module}/helm-charts/nemo-training/"
  namespace = "default"
  reset_values = true
  values = [
    "${file("${path.module}/values.yaml")}"
  ]



  set {
    name  = "nemo_config"
    value = "${file("${path.module}/${local.nccl_config}")}"
  }

  set {
    name = "workload.image"
    value = "us-central1-docker.pkg.dev/deeplearning-images/reproducibility/pytorch-gpu-nemo@sha256:7a84264e71f82f225be639dd20fcf9104c80936c0f4f38f94b88dfb60303c70e"
  }

  set {
    name = "workload.gcsBucketForDataCataPath"
    value = var.checkpoint_bucket
  }

  set {
    name = "workload.gpus"
    value = var.node_count * 8
  }
}

resource "helm_release" "nccl_tests" {
  count     = var.recipe == "gke-nccl" ? 1 : 0
  name      = "nccl-tests"
  provider  = helm
  version   = "0.1.0"
  chart     = "${path.module}/helm-charts/nccl-tests/"
  namespace = "default"
  reset_values = true
  set {
    name = "workload.gcsBucketForDataCataPath"
    value = var.checkpoint_bucket
  }
}
