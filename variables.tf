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

variable "cluster_id" {
  type = string
}

variable "checkpoint_bucket" {
  type = string
}

variable "recipe" {
  type = string
  validation {
    condition     = contains(["llama3.1_7b_nemo_pretraining", "llama3.1_70b_nemo_pretraining", "gke-nccl"], var.recipe)
    error_message = "Invalid recipe value. Must be one of: llama3.1_7b_nemo_pretraining, llama3.1_70b_nemo_pretraining."
  }
}

variable "node_count" {
  type = number
}
