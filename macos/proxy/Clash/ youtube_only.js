function main(config, profileName) {
  config.rules = [
    "DOMAIN-SUFFIX,youtube.com,Lunaire",
    "DOMAIN-SUFFIX,youtu.be,Lunaire",
    "DOMAIN-SUFFIX,googlevideo.com,Lunaire",
    "DOMAIN-SUFFIX,ytimg.com,Lunaire",
    "DOMAIN-SUFFIX,youtube-nocookie.com,Lunaire",
    "DOMAIN,youtubei.googleapis.com,Lunaire",
    "DOMAIN,youtube.googleapis.com,Lunaire",
    "DOMAIN,youtubeembeddedplayer.googleapis.com,Lunaire",
    "DOMAIN,yt3.ggpht.com,Lunaire",
    "MATCH,DIRECT"
  ];
  return config;
}
