[Libretube](https://github.com/libre-tube/LibreTube) is an alternative frontend for YouTube, for Android. 

YouTube has an extremely invasive privacy policy which relies on using user data in unethical ways. They store a lot of your personal data - ranging from ideas, music taste, content, political opinions, and much more than you think.

This project is aimed at improving the users' privacy by being independent from Google and bypassing their data collection.

Therefore, the app is using the [Piped API](https://github.com/TeamPiped/Piped), which uses proxies to circumvent Google's data collection and includes some other additional features.

# Differences to NewPipe 

With NewPipe, the extraction is done locally on your phone, and all the requests sent towards YouTube/Google are done directly from the network you're connected to, which doesn't use a middleman server in between. Therefore, Google can still access information such as the user's IP address. Aside from that, subscriptions can only be stored locally.

LibreTube takes this one step further and proxies all requests via Piped (which uses the NewPipeExtractor). This prevents Google servers from accessing your IP address or any other personal data.
Apart from that, Piped allows syncing your subscriptions between LibreTube and Piped, which can be used on desktop too.

If the NewPipeExtractor breaks, it only requires an update of Piped and not LibreTube itself. Therefore, fixes usually arrive faster than in NewPipe.

While LibreTube only supports YouTube, NewPipe also allows the use of other platforms like SoundCloud, PeerTube, Bandcamp and media.ccc.de.
Both are great clients for watching YouTube videos. It depends on the individual's use case which one fits their needs better.

# Other software that uses Piped

-   [Yattee](https://github.com/yattee/yattee) - an alternative frontend for YouTube, for IOS.
-   [Hyperpipe](https://codeberg.org/Hyperpipe/Hyperpipe) - an alternative privacy respecting frontend for YouTube Music.
-   [Musicale](https://github.com/Bellisario/musicale) - an alternative to YouTube Music, with style.
-   [ytify](https://github.com/n-ce/ytify) - a complementary minimal audio streaming frontend for YouTube.
-   [PsTube](https://github.com/prateekmedia/pstube) - Watch and download videos without ads on Android, Linux, Windows, iOS, and Mac OSX.
-   [Piped-Material](https://github.com/mmjee/Piped-Material) - A fork of Piped, focusing on better performance and a more usable design.
-   [ReacTube](https://github.com/NeeRaj-2401/ReacTube) - Privacy friendly & distraction free Youtube front-end using Piped API.

# References

- [Source](https://github.com/libre-tube/LibreTube)
