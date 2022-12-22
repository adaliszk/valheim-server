# Export Metrics with MTAIL

[Mtail](https://github.com/google/mtail) is a tool written by Google for reading metrics from application logs to be 
exported into a timeseries database or timeseries calculator for alerting and dashboarding.

It fills a monitoring niche by being the glue between applications that do not export their own internal state (other 
than via logs) and existing monitoring systems, such that system operators do not need to patch those applications to 
instrument them or writing custom extraction code for every such application.

Mtail will expose a very minimalistic status panel to review the available metrics endpoints that then you can actively
export (i.e. push) to timeseries databases:
- [collectd](http://collectd.org)
- [graphite](http://graphite.wikidot.com/start)
- [statsd](https://github.com/etsy/statsd)

Or set up a passive exporter (i.e. pull, or scrape based) by:
- [Prometheus](http://prometheus.io)
- Google’s Borgmon

The exporter in this repo is written in a way that you can use it with any official server's output, however, it is meant
to be used together with the vhpretty library for extra data points to work with. The general idea is:
```bash
docker run -d -p 3903:3903 -v /path/to/valheim/console-output.log:/logs/output.log:ro adaliszk/valheim-server-monitoring:metrics 
```
or
```yaml
version: "3.6"

volumes:
  shared-logs: {}

services:

  valheim:
    image: adaliszk/valheim-server:latest # or use specific verison like `0.147.3`
    environment:
      SERVER_NAME: "My custom message in the server list"
      SERVER_PASSWORD: "super!secret"#
    volumes:
      - shared-logs:/logs
    ports:
      - 2456:2456/udp
      - 2457:2457/udp
  
  metrics:
    image: adaliszk/valheim-server-monitoring:metrics
    volumes:
      - shared-logs:/logs:ro
    ports:
      - 3903:3903
```

### Not using `adaliszk/valheim-server` for valheim?

The exported programs are made in a way that you could use it with any Valheim server provided that you have a log file 
hook it up with mtail. So for example, with a LGSM, you could run it like:
```bash
docker run -d -p 3903:3903 -v /home/vhserver/logs/console/vhserver-console.log:/logs/output.log:ro adaliszk/valheim-server:metrics-exporter 
```
Some metrics however, like backup and world filesize information will be not available.

## Prometheus
For now, this project uses Prometheus as the main metrics collector. To set up MTail with prometheus, you just need to
define the scraping config to call the service on the *internal* network:

[prometheus.yml](examples/docker-prometheus.yml) using [docker exporter](https://github.com/prometheus-net/docker_exporter):
```yaml
global:
  # Default is every 1 minute.
  scrape_interval: 5s
  # The default is every 1 minute.
  evaluation_interval: 5s
  # The default is 10s.
  scrape_timeout: 3s

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:

  - job_name: 'valheim-server-metrics'
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ['metrics-exporter:3903']

  - job_name: 'container-metrics'
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ['docker-exporter:9417']
```
then you can set up a [grafana board](examples/docker-grafana-board.json) for example and fine tune it to your needs!
If you using docker-compose you can set this up [very easily using the included pre-configured prometheus image](examples/compose-with-metrics.yml).

## Available metrics

The metrics collection is split into multiple areas - to keep the code clean - but using them with a general resource
exporter together (for example cAdvisor, or prometheus [docker](https://github.com/prometheus-net/docker_exporter)
/[node](https://github.com/prometheus/node_exporter) exporter) you can set up complex alerts and dashboards.

Some patterns:
- the suffix-less metrics are generally the last values, so depending on your scraping frequency you may lose some accuracy
- `*_avg` is a [moving average calculation](https://github.com/google/mtail/blob/master/docs/Programming-Guide.md#computing-moving-averages), 
  note, that this is not 100% accurate!
- `*_sum` is an overall SUM of the metric from the point where the metrics exporter was started
- `*_count` is an overall COUNT of the metric from the point where the metrics exporter was started, note that some 
  suffix-less metrics are also just counts, it should be easy to spot them with common-sense
  

### Server metrics

- `server_id`: the ID assigned from Steam, it's pretty much static
- `server_players_online`: the number of Players online, this does not query the Steam Query port!
- `server_loaded_serialized_files`: how many
- `server_loaded_objects`: how many Objects are loaded into the Memory from the world data
- `server_game_version`: the version of the server (use labels for the proper name)

Server Unload times:
- `server_unload_duration_avg`
- `server_unload_duration`
- `server_unload_duration_sum`
- `server_unload_count`

Garbage Collector:
- `garbage_collector_unloaded_files`
- `garbage_collector_unloaded_objects`
- `garbage_collection_duration_avg`
- `garbage_collection_duration`
- `garbage_collection_duration_sum`
- `garbage_collection_count`
- `garbage_collector_live_objects_duration_avg`
- `garbage_collector_live_objects_duration`
- `garbage_collector_object_mapping_duration_avg`
- `garbage_collector_object_mapping_duration`
- `garbage_collector_mark_objects_duration_avg`
- `garbage_collector_mark_objects_duration`
- `garbage_collector_delete_objects_duration_avg`
- `garbage_collector_delete_objects_duration`


### World metrics

- `world_day`: the last day that was reported when players skipped a night

#### World statistics (constant value per world):
- `world_location_count`
- `world_mountain_point_count`
- `world_mountain_count`
- `world_river_count`
- `world_lake_count`

#### Dungeons (Chunks) load times:
- `world_dungeons_load_duration_avg`
- `world_dungeons_load_duration`
- `world_dungeons_load_duration_sum`
- `world_dungeons_loaded`

#### Locations (sub-Chunk) load times:
- `world_locations_placed_duration_avg`
- `world_location_placed_duration`
- `world_location_placed_duration_sum`
- `world_location_placed`

#### Saves to the disk:
- `world_save_duration_avg`
- `world_save_duration`
- `world_save_duration_sum`
- `world_save_count`

#### Disk usage:

> Note: These endpoints will be not available if you are not using `adaliszk/valheim-server` for your server, but you could
> implement it on your own by writing the following lines into the server log:
> ```
> World "{world_name}" is {bytes} bytes large
> Worlds are {bytes} bytes large
> ```

- `world_size_total_bytes`
- `world_size_bytes` by `name`

### Player metrics
- `player_connected_count` by `steam_id`
- `player_connected_last` by `steam_id`
- `player_disconnected_count` by `steam_id`
- `player_disconnected_last` by `steam_id`
- `player_zdoid_by_steamid` by `steam_id`
- `player_nick_by_steamid` by `steam_id`
- `player_steamid_by_zdoid` by `player_id`
- `player_steamid_by_nick` by `player_nick`
- `player_character` by `steam_id`, `player_id`, `player_nick`
- `player_game_version` by `steam_id`, `version`
- `player_died` by `steam_id`, `player_nick`

### Event metrics
- `server_random_event_possible`: total events possible
- `player_found_location` by `location`: vegvisir stone interaction counter 
- `server_random_event` by `name`: random event counter

### Backups

> Note: These endpoints will be not available if you are not using `adaliszk/valheim-server` for your server, but you could
> implement it on your own by writing the following lines into the server log:
> ```
> Compressing files for "{backup_name}" backup took {elapsed_ms}ms
> Made a backup for "{backup_name}" tat {bytes} bytes large
> Backups are {bytes} large
> ```

- `backup_duration_avg` by `name`
- `backup_duration` by `name`
- `backup_duration_sum` by `name`
- `backup_count` by `name`
- `backups_size_total_bytes`
- `backup_size_bytes_sum` by `name`
- `backup_size_bytes` by `name`
