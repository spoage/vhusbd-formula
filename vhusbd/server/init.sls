{%- from "vhusbd/map.jinja" import vhusbd with context %}

{%- set server_bin = vhusbd.server.binary %}
vhusbd-server:
  file.managed:
    - name: {{ server_bin.install_dir }}/vhusbd
    - source: {{ server_bin.source.get('override', server_bin.source.base ~ server_bin.source.name) }}
    - source_hash: {{ server_bin.source.base ~ "SHA1SUM" }}
    - user: {{ server_bin.user }}
    - group: {{ server_bin.group }}
    - mode: {{ server_bin.mode }}
    - show_diff: False

{%- if vhusbd.server.run_as_service %}
vhusbd-server-init:
  file.managed:
    - name: /etc/init.d/vhusbd
    - source: salt://vhusbd/files/server/init.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - file: vhusbd-server

vhusbd_service:
  service.running:
    - name: vhusbd
    - enable: True
    - require:
      - file: vhusbd-server-init
    - watch:
      - file: vhusbd-server
{%- endif %}
