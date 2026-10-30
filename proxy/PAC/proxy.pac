function FindProxyForURL(url, host) {
    if (
        shExpMatch(host, "github.com") ||
        shExpMatch(host, "githubassets.com") ||
        shExpMatch(host, "*.githubassets.com") ||
        shExpMatch(host, "githubcopilot.com") ||
        shExpMatch(host, "*.githubcopilot.com")
    ) {
        return "SOCKS5 127.0.0.1:1080; SOCKS 127.0.0.1:1080; DIRECT";
    }
    if (shExpMatch(host, "*.youtube.com") ||
        shExpMatch(host, "*.googlevideo.com") ||
        shExpMatch(host, "*.ytimg.com") ||
        shExpMatch(host, "*.ggpht.com") ||
        shExpMatch(host, "youtu.be") ||
        shExpMatch(host, "*.nhacmp3cdn.com")) {
        return "SOCKS5 127.0.0.1:2080; SOCKS 127.0.0.1:2080; DIRECT";
    }
    return "DIRECT";
}
