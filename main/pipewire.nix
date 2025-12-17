{...}: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Define the Virtual Sinks (Sonar Channels)
    extraConfig.pipewire."99-sonar-channels" = {
      "context.objects" = [
        # --- GAME CHANNEL ---
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Sonar-Game";
            "node.description" = "Sonar Game";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
            "monitor.channel-volumes" = "true";
          };
        }
        # --- CHAT CHANNEL ---
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Sonar-Chat";
            "node.description" = "Sonar Chat";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
            "monitor.channel-volumes" = "true";
          };
        }
        # --- MEDIA CHANNEL ---
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Sonar-Media";
            "node.description" = "Sonar Media";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
            "monitor.channel-volumes" = "true";
          };
        }
      ];

      "context.modules" = [
        # --- LOOPBACK FOR GAME ---
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "Sonar-Game-Link";
            "audio.position" = [ "FL" "FR" ];
            "capture.props" = {
              "media.class" = "Stream/Input/Audio";
              "node.target" = "Sonar-Game";
              "stream.capture.sink" = "true"; # <--- CRITICAL: Tells it to look for an Output's monitor, not a Mic
            };
            "playback.props" = {
              "media.class" = "Stream/Output/Audio";
              "node.target" = "auto"; 
            };
          };
        }
        # --- LOOPBACK FOR CHAT ---
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "Sonar-Chat-Link";
            "audio.position" = [ "FL" "FR" ];
            "capture.props" = {
              "media.class" = "Stream/Input/Audio";
              "node.target" = "Sonar-Chat";
              "stream.capture.sink" = "true"; # <--- Add here
            };
            "playback.props" = {
              "media.class" = "Stream/Output/Audio";
              "node.target" = "auto";
            };
          };
        }
        # --- LOOPBACK FOR MEDIA ---
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "Sonar-Media-Link";
            "audio.position" = [ "FL" "FR" ];
            "capture.props" = {
              "media.class" = "Stream/Input/Audio";
              "node.target" = "Sonar-Media";
              "stream.capture.sink" = "true"; # <--- Add here
            };
            "playback.props" = {
              "media.class" = "Stream/Output/Audio";
              "node.target" = "auto";
            };
          };
        }
      ];
    };
  };
}