{%- from "vhusbd/map.jinja" import vhusbd, vhusbd_generic_server_arch_map, vhusbd_optimized_server_arch_map with context %}

{%- set server_bin = vhusbd.server.binary %}
{%- set generic_server_bin_name = vhusbd_generic_server_arch_map.get(grains['cpuarch'], 'vhusbdi386') %}

{# determine the final binary name to use for the file operations #}
{%- if 'name' in server_bin.source %}
  {# if provided, give pillar data the top priority #}
  {%- set server_bin_name = server_bin.source.name %}
{%- elif 'license' not in vhusbd.server %}
  {# if no license is provided, use one of the generic binaries instead of the optimized ones #}
  {%- set server_bin_name = generic_server_bin_name %}
{%- else %}
  {# a license has been provided, so use an optimized server build if possible #}
  {%- if (grains['cpuarch'] == 'armv7l') and ('crc32' in grains['cpu_flags']) %}
    {# Raspberry Pi 2 and 3 both report as armv7l currently, but only the Pi3 has the crc32 cpu flag #}
    {%- set server_bin_name = 'vhusbdarmpi3' %}
  {%- else %}
    {# see if we have a mapping for the specific CPU arch and if not, fall back to the generic builds #}
    {%- set server_bin_name = vhusbd_optimized_server_arch_map.get(grains['cpuarch'], generic_server_bin_name) %}
  {%- endif %}
{%- endif %}

{%- set bin_install_path = server_bin.install_dir ~ "/" ~ server_bin_name %}

vhusbd-server:
  file.managed:
    - name: {{ bin_install_path }}
    - source: {{ server_bin.source.get('override', server_bin.source.base ~ server_bin_name) }}
    - source_hash: {{ server_bin.source.base ~ "SHA1SUM" }}
    - user: {{ server_bin.user }}
    - group: {{ server_bin.group }}
    - mode: {{ server_bin.mode }}
    - show_diff: False

vhusbd-server-link:
  file.symlink:
    - name: {{ server_bin.install_dir }}/vhusbd
    - target: {{ bin_install_path }}
    - user: {{ server_bin.user }}
    - group: {{ server_bin.group }}
    - mode: {{ server_bin.mode }}

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
