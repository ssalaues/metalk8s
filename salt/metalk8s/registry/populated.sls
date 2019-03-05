{%- from "metalk8s/map.jinja" import repo with context %}

{% set images = [
    {
        'name': 'etcd',
        'tag': '3.2.18',
    },
    {
        'name': 'coredns',
        'tag': '1.1.3',
    },
    {
        'name': 'kube-apiserver',
        'tag': '1.11.7',
    },
    {
        'name': 'kube-controller-manager',
        'tag': '1.11.7',
    },
    {
        'name': 'kube-proxy',
        'tag': '1.11.7',
    },
    {
        'name': 'kube-scheduler',
        'tag': '1.11.7',
    },
    {
        'name': 'nginx',
        'tag': '1.15.8',
    },
    {   'name': 'package-repositories',
        'tag': '1.0.0',
    },
    {
        'name': 'salt-master',
        'tag': '2018.3.3-1',
    },
] %}
{% set images_path = '/srv/scality/metalk8s-2.0/images' %}

include:
  - metalk8s.repo

Install skopeo:
  pkg.installed:
    - name: skopeo
    - version: {{ repo.packages.skopeo.version }}
    - require:
      - pkgrepo: Configure {{ repo.packages.skopeo.repository }} repository

{% for image in images %}
Import {{ image.name }} image:
  docker_registry.image_managed:
    - name: localhost:5000/metalk8s-2.0/{{ image.name }}:{{ image.tag }}
    - archive_path: /srv/scality/metalk8s-2.0/images/{{ image.name }}-{{ image.tag }}.tar.gz
    - tls_verify: false
    - require:
      - pkg: Install skopeo
{% endfor %}
