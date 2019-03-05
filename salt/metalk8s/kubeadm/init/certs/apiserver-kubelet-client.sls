{%- from "metalk8s/map.jinja" import kube_api with context %}

{%- set ca_server = salt['mine.get']('*', 'kubernetes_ca_server').keys() %}
{%- if ca_server %}

include:
  - .installed

Create kube-apiserver kubelet client private key:
  x509.private_key_managed:
    - name: /etc/kubernetes/pki/apiserver-kubelet-client.key
    - bits: 2048
    - verbose: False
    - user: root
    - group: root
    - mode: 600
    - makedirs: True
    - dir_mode: 755
    - require:
      - pkg: Install python34-m2crypto

Generate kube-apiserver kubelet client certificate:
  x509.certificate_managed:
    - name: /etc/kubernetes/pki/apiserver-kubelet-client.crt
    - public_key: /etc/kubernetes/pki/apiserver-kubelet-client.key
    - ca_server: {{ ca_server[0] }}
    - signing_policy: {{ kube_api.cert.client_signing_policy }}
    - CN: kube-apiserver-kubelet-client
    - O: "system:masters"
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - dir_mode: 755
    - require:
      - x509: Create kube-apiserver kubelet client private key

{%- else %}

Unable to generate kube-apiserver kubelet client certificate, no CA Server available:
  test.fail_without_changes: []

{%- endif %}
