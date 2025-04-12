# Requires yt-dlp to be installed -> https://github.com/yt-dlp/yt-dlp
yt() {
    yt-dlp "$1" -S res,vcodec:h264,acodec:m4a
}
