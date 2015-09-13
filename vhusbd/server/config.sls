{%- from "vhusbd/map.jinja" import vhusbd with context %}

include:
  - vhusbd.server

{%- set cfg_file = vhusbd.server.config %}
vhusbd-server-config:
  file.managed:
    - name: {{ cfg_file.path }}
    - source: {{ cfg_file.source }}
    - user: {{ cfg_file.user }}
    - group: {{ cfg_file.group }}
    - mode: {{ cfg_file.mode }}
    - template: jinja
    - require:
      - file: vhusbd-server
    - watch_in:
      - service: vhusbd_service

{%- if vhusbd.server.run_as_service %}
vhusbd-stop-before-config:
  service.dead:
    - name: vhusbd
    - prereq_in:
      - file: vhusbd-server-config
    - require_in:
      - service: vhusbd_service
{%- endif %}
