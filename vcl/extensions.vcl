#
# Copyright 2019 Adobe. All rights reserved.
# This file is licensed to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy
# of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
# OF ANY KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.
#

sub hlx_type_pipeline_before {}
sub hlx_type_pipeline_after {}

# try to extract X-Owner, X-Repo, X-Ref from subdomain
# supported patterns are:
# - https://<repo>-<owner>.host.com (if owner does not contain a dash)
# - https://<repo>--<owner>.host.com
# - https://<branch>--<repo>--<owner>.host.com

sub hlx_owner_before {}
sub hlx_owner_after {
    declare local var.o STRING;
  
    # compute a potential owner in the subdomain
    # first, try 2x -- pattern (include branch)
    set var.o = if(req.http.host ~ "(.*)--(.*)--(.*)\..*\..*$", re.group.3, "");

    if (var.o == "") {
        # second, try single -- pattern
        set var.o = if(req.http.host ~ "(.*)--(.*)\..*\..*$", re.group.2, "");
    }

    if (var.o == "") {
        # third, try - pattern
        set var.o = if(req.http.host ~ "(.*)-(.*)\..*\..*$", re.group.2, "");
    }

    if (var.o != "") {
        // override X-Owner
        set req.http.X-Owner = var.o;
    }
}

sub hlx_repo_before {}
sub hlx_repo_after {
    declare local var.o STRING;
    declare local var.r STRING;

    # compute a potential repo in the subdomain
    # first, try 2x -- pattern (include branch)
    set var.o = if(req.http.host ~ "(.*)--(.*)--(.*)\..*\..*$", re.group.3, "");
    set var.r = re.group.2;

    if (var.o == "") {
        # first, try single -- pattern
        set var.o = if(req.http.host ~ "(.*)--(.*)\..*\..*$", re.group.2, "");
        set var.r = re.group.1;
    }

    if (var.o == "") {
        # second, try - pattern
        set var.o = if(req.http.host ~ "(.*)-(.*)\..*\..*$", re.group.2, "");
        set var.r = re.group.1;
    }

    if (var.r != "") {
        # override X-Repo
        set req.http.X-Repo = var.r;
    }
}

sub hlx_ref_before {}
sub hlx_ref_after {
    declare local var.ref STRING;
    # compute a potential ref in the subdomain
    # try -- pattern (only case that includes branch)
    set var.ref = if(req.http.host ~ "(.*)--(.*)--(.*)\..*\..*$", re.group.1, "");

    if (var.ref != "") {
        # override X-Ref
        set req.http.X-Ref= var.ref;
    }
}
