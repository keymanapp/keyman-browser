package com.keyman.keyman_browser;

import java.util.List;
import android.os.Bundle;
import io.flutter.plugin.common.MethodCall;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.keyman.engine.KMManager;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.annotation.NonNull;
import android.util.Log;


public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.example.font_channel";

  private MethodChannel channel;

  private final BroadcastReceiver fontReceiver = new BroadcastReceiver() {
  @Override
  public void onReceive(Context context, Intent intent) {
    if ("com.keyman.keyman_browser.RECEIVE_FONT_NAME".equals(intent.getAction())) {
      String fontName = intent.getStringExtra("fontName");

      if (channel != null && fontName != null) {
        try {
          channel.invokeMethod("onFontNameReceived", fontName);
        } catch (Exception e) {
          Log.e("FontReceiver", "Failed to send font to Flutter: " + e.getMessage());
        }
      } else {
        Log.w("FontReceiver", "Flutter channel not ready, or fontName is null");
      }
    }
  }
};


  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

    // Register the BroadcastReceiver
    IntentFilter filter = new IntentFilter("com.keyman.keyman_browser.RECEIVE_FONT_NAME");
    registerReceiver(fontReceiver, filter, Context.RECEIVER_EXPORTED);
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    unregisterReceiver(fontReceiver);
  }
}
