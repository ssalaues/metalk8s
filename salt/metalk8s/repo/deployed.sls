{%- from "metalk8s/map.jinja" import repo with context %}

{%- set metalk8s_version = '2.0' %}
{%- set package_repositories_name = 'package-repositories' %}
{%- set package_repositories_version = '1.0.0' %}
{%- set package_repositories_image = 'localhost:5000/metalk8s-' ~
    metalk8s_version ~ '/' ~ 'nginx:1.15.8' %}
{%- set packages_path = '/srv/scality/metalk8s-' ~ metalk8s_version ~ '/packages' %}
{%- set nginx_configuration_path = '/var/lib/metalk8s/packages-repositories/nginx.conf' %}

Generate package-repositories nginx configuration:
  file.managed:
    - name: {{ nginx_configuration_path }}
    - source: salt://metalk8s/repo/files/nginx.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: true
    - backup: false
    - defaults:
        listening_port: {{ repo.port }}

Install package-repositories manifest:
  file.managed:
    - name: /etc/kubernetes/manifests/package-repositories-pod.yaml
    - source: salt://metalk8s/repo/files/package-repositories-pod.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: false
    - backup: false
    - defaults:
        container_port: {{ repo.port }}
        image: {{ package_repositories_image }}
        name: {{ package_repositories_name }}
        version: {{ package_repositories_version }}
        packages_path: {{ packages_path }}
        nginx_configuration_path: {{ nginx_configuration_path }}
    - require:
      - file: Generate package-repositories nginx configuration
