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

import android.os.Handler;
import android.provider.Settings;
import android.database.ContentObserver;


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

   // Content observer to monitor keyboard changes
  private final ContentObserver inputMethodObserver = new ContentObserver(new Handler()) {
    @Override
    public void onChange(boolean selfChange) {
      String currentInputMethod = Settings.Secure.getString(
        getContentResolver(),
        Settings.Secure.DEFAULT_INPUT_METHOD
      );

      // Log.d("InputMethodObserver", "Current input method: " + currentInputMethod);

      if (channel == null || currentInputMethod == null) return;

      if (currentInputMethod.toLowerCase().contains("keyman")) {
        channel.invokeMethod("onKeymanKeyboardActive", null);
        Log.d("InputMethodObserver", "Keyman keyboard activated → notifying Flutter to inject font.");
      } else {
        channel.invokeMethod("onUseDefaultFont", null);
        Log.d("InputMethodObserver", "Switched away from Keyman → notifying Flutter to reset font.");
      }
    }
  };




  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

    IntentFilter filter = new IntentFilter("com.keyman.keyman_browser.RECEIVE_FONT_NAME");
    registerReceiver(fontReceiver, filter, Context.RECEIVER_EXPORTED);

    getContentResolver().registerContentObserver(
      Settings.Secure.getUriFor(Settings.Secure.DEFAULT_INPUT_METHOD),
      false,
      inputMethodObserver
    );
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    unregisterReceiver(fontReceiver);
    getContentResolver().unregisterContentObserver(inputMethodObserver);
  }
}
