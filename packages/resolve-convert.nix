{ writeShellApplication, ffmpeg }:
writeShellApplication {
  name = "resolve-convert";
  runtimeInputs = [ ffmpeg ];
  text = ''
    mkdir -p resolve_ready

    convert_one() {
      local file="$1"
      filename=$(basename -- "$file")
      noext="''${filename%.*}"
      echo "---------------------------------------------------"
      echo "Processing: $file"
      echo "---------------------------------------------------"
      ffmpeg -i "$file" \
        -c:v mpeg4 \
        -q:v 3 \
        -c:a pcm_s16le \
        "resolve_ready/''${noext}.mov"
    }

    if [ $# -eq 1 ]; then
      echo "Starting conversion for DaVinci Resolve..."
      convert_one "$1"
    else
      echo "Starting batch conversion for DaVinci Resolve..."
      for file in *.{mp4,MP4}; do
        [ -e "$file" ] || continue
        convert_one "$file"
      done
    fi
    echo "All done! Your files are waiting in the 'resolve_ready' folder."
  '';
}
