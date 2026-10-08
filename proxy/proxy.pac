function FindProxyForURL(url, host) {
    if (
        shExpMatch(host, "githubassets.com") ||
        shExpMatch(host, "*.githubassets.com") ||
        shExpMatch(host, "githubcopilot.com") ||
        shExpMatch(host, "*.githubcopilot.com")
    ) {
        return "SOCKS5 127.0.0.1:1080; SOCKS 127.0.0.1:1080; DIRECT";
    }
    return "DIRECT";
}
