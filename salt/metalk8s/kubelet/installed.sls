{%- from "metalk8s/map.jinja" import repo with context %}
{%- from "metalk8s/map.jinja" import kubelet with context %}

include:
  - metalk8s.repo
{%- if kubelet.container_engine %}
  - metalk8s.{{ kubelet.container_engine }}
{%- endif %}

# TODO: Maybe not needed in offline because embedded in the kubernetes repository
Install kubelet dependencies:
  pkg.installed:
    - pkgs:
      - ebtables
      - socat
      - conntrack-tools

Install and configure cri-tools:
  pkg.installed:
    - name: cri-tools
    - version: {{ repo.packages['cri-tools'].version }}
    - fromrepo: {{ repo.packages['cri-tools'].repository }}
    - require:
      - pkgrepo: Configure {{ repo.packages['cri-tools'].repository }} repository
  file.serialize:
    - name: /etc/crictl.yaml
    - dataset:
        runtime-endpoint: {{ kubelet.service.options.get("container-runtime-endpoint") }}
        image-endpoint: {{ kubelet.service.options.get("container-runtime-endpoint") }}
    - merge_if_exists: true
    - user: root
    - group: root
    - mode: '0644'
    - formatter: yaml

Install kubelet:
  pkg.installed:
    - name: kubelet
    - version: {{ repo.packages.kubelet.version }}
    - fromrepo: {{ repo.packages.kubelet.repository }}
    - require:
      - pkgrepo: Configure {{ repo.packages.kubelet.repository }} repository
