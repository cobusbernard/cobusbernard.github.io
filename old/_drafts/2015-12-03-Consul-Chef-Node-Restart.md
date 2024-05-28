* consul_config[consul] action create
  * directory[/etc] action create (up to date)
  * file[/etc/consul.json] action create
    - update content in file /etc/consul.json from d7f79e to 512376
    --- /etc/consul.json	2015-12-04 14:38:31.430312949 +0200
    +++ /etc/.consul.json20151204-3939-1cnj9st	2015-12-04 14:38:55.117673237 +0200
    @@ -14,9 +14,9 @@
       },
       "server": true,
       "start_join": [
    +    "coreos-cpt-01",
         "coreos-cpt-02",
    -    "coreos-cpt-03",
    -    "coreos-cpt-01"
    +    "coreos-cpt-03"
       ],
       "ui_dir": "/srv/consul-ui/current/dist",
       "verify_incoming": false,

Recipe: consul::default
 * consul_service[consul] action restart
   * poise_service[consul] action restart
     * service[consul] action restart
       - restart service service[consul]

               instances = search(:node, "role:consul-server AND chef_environment:#{node.chef_environment}")
               instances.sort_by!{ |n| n[:hostname] }
               instances.map!{ |n| n[:hostname] }

               #search(:node, "role:consul-server AND chef_environment:#{node.chef_environment}", :filter_result => { 'hostname' => ['hostname'] }).each do |result|
               #  Chef::Log.info("Node: #{result}")
               #  instances << result['hostname']
               #end
