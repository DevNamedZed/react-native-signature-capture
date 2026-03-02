package com.rssignaturecapture;

import android.util.Log;
import android.view.ViewGroup;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;

import android.util.Base64;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;

import android.app.Activity;
import android.content.pm.ActivityInfo;

import java.lang.ref.WeakReference;

public class RSSignatureCaptureMainView extends LinearLayout implements OnClickListener, RSSignatureCaptureView.SignatureCallback {
  LinearLayout buttonsLayout;
  RSSignatureCaptureView signatureView;

  WeakReference<Activity> mActivityRef;
  int mOriginalOrientation;
  boolean saveFileInExtStorage = false;
  String viewMode = "portrait";
  boolean showBorder = true;
  boolean showNativeButtons = true;
  boolean showTitleLabel = true;
  int maxSize = 500;

  public RSSignatureCaptureMainView(Context context, Activity activity) {
    super(context);
    Log.d("React:", "RSSignatureCaptureMainView(Constructor)");
    mOriginalOrientation = activity.getRequestedOrientation();
    mActivityRef = new WeakReference<>(activity);

    this.setOrientation(LinearLayout.VERTICAL);
    this.signatureView = new RSSignatureCaptureView(context, this);
    this.buttonsLayout = this.buttonsLayout();
    this.addView(this.buttonsLayout);
    this.addView(signatureView);

    setLayoutParams(new android.view.ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT));
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    Activity activity = mActivityRef.get();
    if (activity != null && !activity.isFinishing()) {
      activity.setRequestedOrientation(mOriginalOrientation);
    }
  }

  public RSSignatureCaptureView getSignatureView() {
    return signatureView;
  }

  public void setSaveFileInExtStorage(Boolean saveFileInExtStorage) {
    if (saveFileInExtStorage != null) {
      this.saveFileInExtStorage = saveFileInExtStorage;
    }
  }

  public void setViewMode(String viewMode) {
    if (viewMode == null) return;
    this.viewMode = viewMode;

    Activity activity = mActivityRef.get();
    if (activity == null || activity.isFinishing()) return;

    if (viewMode.equalsIgnoreCase("portrait")) {
      activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    } else if (viewMode.equalsIgnoreCase("landscape")) {
      activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
    }
  }

  public void setShowNativeButtons(Boolean showNativeButtons) {
    if (showNativeButtons == null) return;
    this.showNativeButtons = showNativeButtons;
    if (showNativeButtons) {
      Log.d("Added Native Buttons", "Native Buttons:" + showNativeButtons);
      buttonsLayout.setVisibility(View.VISIBLE);
    } else {
      buttonsLayout.setVisibility(View.GONE);
    }
  }

  public void setMaxSize(int size) {
    if (size > 0) {
      this.maxSize = size;
    }
  }

  private LinearLayout buttonsLayout() {
    LinearLayout linearLayout = new LinearLayout(this.getContext());
    Button saveBtn = new Button(this.getContext());
    Button clearBtn = new Button(this.getContext());

    linearLayout.setOrientation(LinearLayout.HORIZONTAL);
    linearLayout.setBackgroundColor(Color.WHITE);

    saveBtn.setText("Save");
    saveBtn.setTag("Save");
    saveBtn.setOnClickListener(this);

    clearBtn.setText("Reset");
    clearBtn.setTag("Reset");
    clearBtn.setOnClickListener(this);

    linearLayout.addView(saveBtn);
    linearLayout.addView(clearBtn);

    return linearLayout;
  }

  @Override
  public void onClick(View v) {
    String tag = v.getTag().toString().trim();

    if (tag.equalsIgnoreCase("save")) {
      this.saveImage();
    } else if (tag.equalsIgnoreCase("Reset")) {
      this.signatureView.clearSignature();
    }
  }

  final void saveImage() {
    if (this.signatureView.isEmpty()) {
      return;
    }

    Bitmap fullBitmap = this.signatureView.getSignature();
    if (fullBitmap == null) return;

    File myDir = getContext().getExternalFilesDir("/saved_signature");
    if (myDir == null) {
      fullBitmap.recycle();
      return;
    }

    if (!myDir.exists()) {
      myDir.mkdirs();
    }

    String fname = "signature.png";

    File file = new File(myDir, fname);
    if (file.exists()) {
      file.delete();
    }

    try {
      Log.d("React Signature", "Save file-======:" + saveFileInExtStorage);
      if (saveFileInExtStorage) {
        try (FileOutputStream out = new FileOutputStream(file)) {
          fullBitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
          out.flush();
        }
      }

      Bitmap resizedBitmap = getResizedBitmap(fullBitmap);
      try (ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {
        resizedBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);

        byte[] byteArray = byteArrayOutputStream.toByteArray();
        String encoded = Base64.encodeToString(byteArray, Base64.NO_WRAP);

        WritableMap event = Arguments.createMap();
        event.putString("pathName", file.getAbsolutePath());
        event.putString("encoded", encoded);
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onSaveEvent", event);
      } finally {
        if (resizedBitmap != fullBitmap) {
          resizedBitmap.recycle();
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      fullBitmap.recycle();
    }
  }

  public Bitmap getResizedBitmap(Bitmap image) {
    Log.d("React Signature", "maxSize:" + maxSize);
    int width = image.getWidth();
    int height = image.getHeight();

    if (width <= 0 || height <= 0) return image;

    float bitmapRatio = (float) width / (float) height;
    if (bitmapRatio > 1) {
      width = maxSize;
      height = (int) (width / bitmapRatio);
    } else {
      height = maxSize;
      width = (int) (height * bitmapRatio);
    }

    width = Math.max(1, width);
    height = Math.max(1, height);

    return Bitmap.createScaledBitmap(image, width, height, true);
  }

  public void reset() {
    if (this.signatureView != null) {
      this.signatureView.clearSignature();
    }
  }

  @Override
  public void onDragged() {
    if (!isAttachedToWindow()) return;
    WritableMap event = Arguments.createMap();
    event.putBoolean("dragged", true);
    ReactContext reactContext = (ReactContext) getContext();
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onDragEvent", event);
  }
}
