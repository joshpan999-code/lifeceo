import { CapacitorConfig } from '@capacitor/core';

const config: CapacitorConfig = {
  appId: 'com.lifeceo.app',
  appName: '人生CEO',
  webDir: 'public',
  server: {
    androidScheme: 'https'
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 3000,
      backgroundColor: '#1a1a2e',
      showSpinner: false,
    },
    LocalNotifications: {
      smallIcon: 'ic_stat_icon_config_sample',
      iconColor: '#e94560',
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#1a1a2e',
    },
  },
};

export default config;
