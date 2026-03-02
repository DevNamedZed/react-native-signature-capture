package com.rssignaturecapture;

import android.app.Activity;
import android.util.Log;
import android.graphics.Color;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class RSSignatureCaptureViewManager extends ViewGroupManager<RSSignatureCaptureMainView> {

	public static final String PROPS_SAVE_IMAGE_FILE = "saveImageFileInExtStorage";
	public static final String PROPS_VIEW_MODE = "viewMode";
	public static final String PROPS_SHOW_NATIVE_BUTTONS = "showNativeButtons";
	public static final String PROPS_MAX_SIZE = "maxSize";
	public static final String PROPS_MIN_STROKE_WIDTH = "minStrokeWidth";
	public static final String PROPS_MAX_STROKE_WIDTH = "maxStrokeWidth";
	public static final String PROPS_STROKE_COLOR = "strokeColor";
	public static final String PROPS_BACKGROUND_COLOR = "backgroundColor";

	public static final int COMMAND_SAVE_IMAGE = 1;
	public static final int COMMAND_RESET_IMAGE = 2;

	@Override
	public String getName() {
		return "RSSignatureView";
	}

	@ReactProp(name = PROPS_SAVE_IMAGE_FILE)
	public void setSaveImageFileInExtStorage(RSSignatureCaptureMainView view, @Nullable Boolean saveFile) {
		Log.d("setFileInExtStorage:", "" + saveFile);
		if (view != null && saveFile != null) {
			view.setSaveFileInExtStorage(saveFile);
		}
	}

	@ReactProp(name = PROPS_VIEW_MODE)
	public void setViewMode(RSSignatureCaptureMainView view, @Nullable String viewMode) {
		Log.d("setViewMode:", "" + viewMode);
		if (view != null && viewMode != null) {
			view.setViewMode(viewMode);
		}
	}

	@ReactProp(name = PROPS_SHOW_NATIVE_BUTTONS)
	public void setPropsShowNativeButtons(RSSignatureCaptureMainView view, @Nullable Boolean showNativeButtons) {
		Log.d("showNativeButtons:", "" + showNativeButtons);
		if (view != null && showNativeButtons != null) {
			view.setShowNativeButtons(showNativeButtons);
		}
	}

	@ReactProp(name = PROPS_MAX_SIZE)
	public void setPropsWidth(RSSignatureCaptureMainView view, @Nullable Integer maxSize) {
		Log.d("maxSize:", "" + maxSize);
		if (view != null && maxSize != null && maxSize > 0) {
			view.setMaxSize(maxSize);
		}
	}

	@ReactProp(name = PROPS_MIN_STROKE_WIDTH)
	public void setPropsMinStrokeWidth(RSSignatureCaptureMainView view, @Nullable Integer minStrokeWidth) {
		Log.d("minStrokeWidth:", "" + minStrokeWidth);
		if (view != null && minStrokeWidth != null && minStrokeWidth > 0) {
			view.getSignatureView().setMinStrokeWidth(minStrokeWidth);
		}
	}

	@ReactProp(name = PROPS_MAX_STROKE_WIDTH)
	public void setPropsMaxStrokeWidth(RSSignatureCaptureMainView view, @Nullable Integer maxStrokeWidth) {
		Log.d("maxStrokeWidth:", "" + maxStrokeWidth);
		if (view != null && maxStrokeWidth != null && maxStrokeWidth > 0) {
			view.getSignatureView().setMaxStrokeWidth(maxStrokeWidth);
		}
	}

	@ReactProp(name = PROPS_STROKE_COLOR)
	public void setPropsStrokeColor(RSSignatureCaptureMainView view, @Nullable String color) {
		Log.d("strokeColor:", "" + color);
		if (view != null && color != null) {
			try {
				view.getSignatureView().setStrokeColor(Color.parseColor(color));
			} catch (IllegalArgumentException e) {
				Log.e("RSSignatureCapture", "Invalid strokeColor: " + color, e);
			}
		}
	}

	@ReactProp(name = PROPS_BACKGROUND_COLOR)
	public void setPropsBackgroundColor(RSSignatureCaptureMainView view, @Nullable String color) {
		if (color == null || view == null) return;

		int parsed;
		try {
			if (color.equalsIgnoreCase("transparent")) {
				parsed = Color.TRANSPARENT;
			} else {
				parsed = Color.parseColor(color);
			}
		} catch (IllegalArgumentException e) {
			Log.e("RSSignatureCapture", "Invalid backgroundColor: " + color, e);
			return;
		}

		Log.d("backgroundColor:", "" + color);
		view.getSignatureView().setBackgroundColor(parsed);
	}

	@Override
	public RSSignatureCaptureMainView createViewInstance(ThemedReactContext context) {
		Log.d("React", " View manager createViewInstance:");
		Activity activity = context.getCurrentActivity();
		if (activity == null) {
			throw new IllegalStateException("RSSignatureCapture requires an active Activity");
		}
		return new RSSignatureCaptureMainView(context, activity);
	}

	@Override
	public Map<String, Integer> getCommandsMap() {
		Log.d("React", " View manager getCommandsMap:");
		return MapBuilder.of(
				"saveImage",
				COMMAND_SAVE_IMAGE,
				"resetImage",
				COMMAND_RESET_IMAGE);
	}

	@Override
	public void receiveCommand(
			RSSignatureCaptureMainView view,
			int commandType,
			@Nullable ReadableArray args) {
		if (view == null) return;
		switch (commandType) {
			case COMMAND_SAVE_IMAGE: {
				view.saveImage();
				return;
			}
			case COMMAND_RESET_IMAGE: {
				view.reset();
				return;
			}
			default:
				throw new IllegalArgumentException(String.format(
						"Unsupported command %d received by %s.",
						commandType,
						getClass().getSimpleName()));
		}
	}

	@Override
	public void receiveCommand(
			RSSignatureCaptureMainView view,
			String commandId,
			@Nullable ReadableArray args) {
		if (view == null) return;
		switch (commandId) {
			case "saveImage":
				view.saveImage();
				break;
			case "resetImage":
				view.reset();
				break;
			default:
				throw new IllegalArgumentException(String.format(
						"Unsupported command %s received by %s.",
						commandId,
						getClass().getSimpleName()));
		}
	}

	@Override
	public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
		return MapBuilder.<String, Object>builder()
				.put("onSaveEvent", MapBuilder.of("registrationName", "onSaveEvent"))
				.put("onDragEvent", MapBuilder.of("registrationName", "onDragEvent"))
				.build();
	}
}
