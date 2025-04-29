# Comparison between jackett and prowlarr

Both Jackett and Prowlarr are indexer management applications commonly used with media automation tools like Sonarr and Radarr. Here's how they compare:

## Similarities

- Both serve as proxy servers that translate searches from applications into queries that torrent trackers and usenet indexers can understand
- Both can integrate with services like Sonarr, Radarr, Lidarr, and Readarr
- Both are open-source projects
- Both support a wide range of indexers

## [Jackett](https://github.com/Jackett/Jackett)

- **Age**: Older, more established project
- **Popular**: It has 1.4k forks and 13.1k stars
- **More active**: In the [last month](https://github.com/Jackett/Jackett/pulse/monthly) as of 2025-03 it had activity on 117 issues and 11 pull requests
- **Architecture**: Standalone application with its own web interface
- **Integration**: Requires manual setup in each \*arr application with individual API keys
- **Updates**: Requires manual updating of indexers
- **Configuration**: Each client (\*arr application) needs its own Jackett instance configuration
- **Proxy Requests**: All search requests go through Jackett

## [Prowlarr](https://github.com/Prowlarr/Prowlarr)

- **Origin**: Developed by the Servarr team (same developers as Sonarr, Radarr, etc.)
- **Architecture**: Follows the same design patterns as other \*arr applications
- **Integration**: Direct synchronization with other \*arr apps
- **Updates**: Automatically updates indexers
- **Configuration**: Centralized management - configure once, sync to all clients
- **API**: Native integration with other \*arr applications
- **History**: Keeps a search history and statistics
- **Notifications**: Better notification system
- **Less popular**: It has 213 forks and 4.6k stars
- **Way less active**: In the [last month](https://github.com/Prowlarr/Prowlarr/pulse/monthly) as of 2025-03 it had activity on 10 issues and 3 pull requests
- Supports to be protected behind [authentik](authentik.md) and still be protected with basic auth

## Key Differences

1. **Management**: Prowlarr can push indexer configurations directly to your \*arr applications, while Jackett requires manual configuration in each app
2. **Maintenance**: Prowlarr generally requires less maintenance as it handles updates more seamlessly
3. **UI/UX**: Prowlarr has a more modern interface that matches other \*arr applications
4. **Integration**: Prowlarr was specifically designed to work with the \*arr ecosystem

## Recommendation

Prowlarr is generally considered the superior option if you're using multiple \*arr applications, as it offers better integration, centralized management, and follows the same design patterns as the other tools in the ecosystem. However, Jackett still is more popular and active, works well and might be preferable if you're already using it and comfortable with its setup.
