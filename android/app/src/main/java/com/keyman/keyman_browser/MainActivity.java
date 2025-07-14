package com.keyman.keyman_browser;

import java.util.List;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.keyman.engine.KMManager;
import com.keyman.engine.data.Keyboard;
import com.keyman.engine.KeyboardEventHandler.OnKeyboardEventListener;
import com.keyman.engine.KMManager.KeyboardType;
import android.app.AlertDialog;
import android.content.DialogInterface;

import android.content.Context;
import android.provider.Settings;
import android.view.inputmethod.InputMethodManager;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.kmmanager/font";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Keyman Engine
        KMManager.initialize(getApplicationContext(), KMManager.KeyboardType.KEYBOARD_TYPE_INAPP);

         Keyboard kbInfo = new Keyboard(
            "english_test",      // packageID
            "english_test",      // keyboardID
            "english_test",      // keyboard name
            "en",                // language ID
            "English",           // language name
            "1.0",               // version
            null,                // help link
            "",                  // kmp URL
            true,                // is new
            "", 
            ""
        );
        KMManager.addKeyboard(this, kbInfo);
        
    } 


    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
          .setMethodCallHandler((call, result) -> {
            if (call.method.equals("getKeyboardFontFilename")) {
                List<Keyboard> keyboardsList = KMManager.getKeyboardsList(this);

                if (keyboardsList == null || keyboardsList.isEmpty()) {
                    runOnUiThread(() -> {
                        showNoKeyboardsAlert();
                        KMManager.showKeyboardPicker(MainActivity.this, KMManager.KeyboardType.KEYBOARD_TYPE_INAPP);
                    });
                    result.success("");  
                    return;
                }

                Keyboard keyboardInfo = KMManager.getCurrentKeyboardInfo(this);

                if (keyboardInfo != null) {
                    String font = keyboardInfo.getFont();
                    String packageID = keyboardInfo.getPackageID();

                    if (font != null && !font.isEmpty()) {
                        // String fontPath = getApplicationContext().getFilesDir().getAbsolutePath()
                        //     + "/keyman/" + packageID + "/" + font;
                        String fontPath = "/data/user/0/com.keyman.keyman_browser/app_data/packages/"
                        + packageID + "/" + font;

                          runOnUiThread(() -> showFontAvailableAlert(font));
                        result.success(fontPath);
                    } else {
                        runOnUiThread(() -> showFontUnavailableAlert());
                        result.success("");  // Fallback
                    }
                } else {
                    runOnUiThread(() -> showFontUnavailableAlert());
                    result.success("");  // Fallback
                }
            } else {
                result.notImplemented();
            }
          });
    }


    private void showNoKeyboardsAlert() {
    new AlertDialog.Builder(this)
      .setTitle("No Keyboards Installed")
      .setMessage("Please install a keyboard to use this feature.")
      .setPositiveButton(android.R.string.ok, (dialog, which) -> dialog.dismiss())
      .setCancelable(false)
      .show();
    }

    private void showFontUnavailableAlert() {
        new AlertDialog.Builder(this)
          .setTitle("Font Not Found")
          .setMessage("The keyboard font could not be loaded. The app will use a default font instead.")
          .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
              public void onClick(DialogInterface dialog, int which) {
                  dialog.dismiss();
              }
          })
          .setCancelable(false)
          .show();
    }

    private void showFontAvailableAlert(String fontName) {
    new AlertDialog.Builder(this)
        .setTitle("Font Available")
        .setMessage("The keyboard font '" + fontName + "' is available and will be used.")
        .setPositiveButton(android.R.string.ok, (dialog, which) -> dialog.dismiss())
        .setCancelable(false)
        .show();
    }



}
