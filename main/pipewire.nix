{ }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire."99-sonar-devices" = {
      "context.modules" = [
        # 1. Create the "Game" Virtual Sink
        {
          name = "libpipewire-module-null-audio-sink";
          args = {
            "node.name" = "sonar_game";
            "node.description" = "Sonar Game";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
        # 2. Loop "Game" audio to your physical speakers
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "sonar_game_loopback";
            "capture.props" = {
              "node.target" = "sonar_game";
              "media.class" = "Stream/Input/Audio";
            };
            "playback.props" = {
              "media.class" = "Stream/Output/Audio";
              "node.target" = ""; # Empty string = auto-connect to default speakers
            };
          };
        }

        # 3. Create the "Chat" Virtual Sink
        {
          name = "libpipewire-module-null-audio-sink";
          args = {
            "node.name" = "sonar_chat";
            "node.description" = "Sonar Chat";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
        # 4. Loop "Chat" audio to speakers
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "sonar_chat_loopback";
            "capture.props" = {
              "node.target" = "sonar_chat";
              "media.class" = "Stream/Input/Audio";
            };
            "playback.props" = {
              "media.class" = "Stream/Output/Audio";
              "node.target" = "";
            };
          };
        }

        # 5. Create the "Media" Virtual Sink
        {
          name = "libpipewire-module-null-audio-sink";
          args = {
            "node.name" = "sonar_media";
            "node.description" = "Sonar Media";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
        # 6. Loop "Media" audio to speakers
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "sonar_media_loopback";
            "capture.props" = {
              "node.target" = "sonar_media";
              "media.class" = "Stream/Input/Audio";
            };
            "playback.props" = {
              "media.class" = "Stream/Output/Audio";
              "node.target" = "";
            };
          };
        }
      ];
    };
  };
}
