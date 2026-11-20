function main(config, profileName) {
  if (!config.dns) config.dns = {};
  if (!config.dns['fake-ip-filter']) config.dns['fake-ip-filter'] = [];

  config.dns['fake-ip-filter'].push('+.registry.docker.internal');
  config.dns['fake-ip-filter'].push('+.docker.com');
  config.dns['fake-ip-filter'].push('+.docker.io');
  config.dns['fake-ip-filter'].push('+.ghcr.io');
  config.dns['fake-ip-filter'].push('+.huecker.io');
  config.dns['fake-ip-filter'].push('+.docker4u.ru');
  config.dns['fake-ip-filter'].push('+.timeweb.cloud');
  config.dns['fake-ip-filter'].push('+.v6.army');
  config.dns['fake-ip-filter'].push('+.daocloud.io');
  config.dns['fake-ip-filter'].push('+.dockermirror.com');
  config.dns['fake-ip-filter'].push('+.gcr.io');

  config.rules = [
    "IP-CIDR,95.181.212.218/32,DIRECT,no-resolve",
    "DOMAIN-SUFFIX,registry.docker.internal,DIRECT",
    "DOMAIN-SUFFIX,docker.com,DIRECT",
    "DOMAIN-SUFFIX,docker.io,DIRECT",
    "DOMAIN-SUFFIX,ghcr.io,DIRECT",
    "DOMAIN-SUFFIX,huecker.io,DIRECT",
    "DOMAIN-SUFFIX,docker4u.ru,DIRECT",
    "DOMAIN-SUFFIX,timeweb.cloud,DIRECT",
    "DOMAIN-SUFFIX,v6.army,DIRECT",
    "DOMAIN-SUFFIX,daocloud.io,DIRECT",
    "DOMAIN-SUFFIX,dockermirror.com,DIRECT",
    "DOMAIN-SUFFIX,gcr.io,DIRECT",
    "DOMAIN-SUFFIX,youtube.com,Lunaire",
    "DOMAIN-SUFFIX,youtu.be,Lunaire",
    "DOMAIN-SUFFIX,googlevideo.com,Lunaire",
    "DOMAIN-SUFFIX,ytimg.com,Lunaire",
    "DOMAIN-SUFFIX,youtube-nocookie.com,Lunaire",
    "DOMAIN-KEYWORD,googleapis.com,Lunaire",
    "DOMAIN-KEYWORD,ggpht.com,Lunaire",
    "MATCH,DIRECT"
  ];
  return config;
}
