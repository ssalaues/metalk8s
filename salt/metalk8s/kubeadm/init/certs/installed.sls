{%- from "metalk8s/map.jinja" import repo with context %}

include:
  - metalk8s.repo

Install python34-m2crypto:
  pkg.installed:
    - name: python34-m2crypto
    - version: {{ repo.packages['python34-m2crypto'].version }}
    - require:
      - pkgrepo: Configure {{ repo.packages['python34-m2crypto'].repository }} repository
